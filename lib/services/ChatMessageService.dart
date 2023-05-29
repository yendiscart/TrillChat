import 'dart:io';

import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/ContactModel.dart';
import '../../models/UserModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ChatMessageService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference userRef;
  FirebaseStorage _storage = FirebaseStorage.instance;

  ChatMessageService() {
    ref = fireStore.collection(MESSAGES_COLLECTION);
    userRef = fireStore.collection(USER_COLLECTION);
  }

  Query chatMessagesWithPagination({String? currentUserId, required String receiverUserId}) {
    return ref!.doc(currentUserId).collection(receiverUserId).orderBy("createdAt", descending: true);
  }

  Future<DocumentReference> addMessage(ChatMessageModel data) async {
    var doc = await ref!.doc(data.senderId).collection(data.receiverId!).add(data.toJson());
    doc.update({'id': doc.id});
    Map<String, dynamic> sendData = {'id': doc.id};
    sendData.putIfAbsent("isEncrypt", () => true);
    return doc;
  }

  Future<void> addMessageToDb({required DocumentReference senderDoc, required ChatMessageModel data, UserModel? sender, UserModel? user, File? image, bool isRequest = false}) async {
    String imageUrl = '';

    if (image != null) {
      String fileName = basename(image.path);
      Reference storageRef = _storage.ref().child("$CHAT_DATA_IMAGES/${getStringAsync(userId)}/$fileName");

      UploadTask uploadTask = storageRef.putFile(image);

      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;

          fileList.removeWhere((element) => element.id == senderDoc.id);
        }).catchError((e) {
          toast(e.toString());
        });
      }).catchError((e) {
        toast(e.toString());
      });
    }

    updateChatDocument(senderDoc, image: image, imageUrl: imageUrl);

    userRef.doc(data.senderId).update({"lastMessageTime": data.createdAt});

    addToContacts(senderId: data.senderId, receiverId: data.receiverId, isRequest: isRequest);

    DocumentReference receiverDoc = await ref!.doc(data.receiverId).collection(data.senderId!).add(data.toJson());

    updateChatDocument(receiverDoc, image: image, imageUrl: imageUrl);

    userRef.doc(data.receiverId).update({"lastMessageTime": data.createdAt});
  }

  // ignore: body_might_complete_normally_nullable
  DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
    Map<String, dynamic> sendData = {'id': data.id};

    if (image != null || imageUrl!=null) {
      sendData.putIfAbsent('photoUrl', () => imageUrl);
    }
    data.update(sendData);
  }

  addLatLong(ChatMessageModel data, {String? lat, String? long}) {
    Map<String, dynamic> sendData = {'id': data.id};

    ref!.doc(data.id).set({'currentLat': lat, 'currentLong': long}, SetOptions(merge: true)).then((value) {
      //Do your stuff.
    });

    sendData.putIfAbsent('current_lat', () => lat);
    sendData.putIfAbsent('current_lat', () => long);
  }

  DocumentReference getContactsDocument({String? of, String? forContact}) {
    return userRef.doc(of).collection(CONTACT_COLLECTION).doc(forContact);
  }

  addToContacts({String? senderId, String? receiverId, bool isRequest = false}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    if (!isRequest) {
      await addToReceiverContacts(senderId, receiverId, currentTime);
    }
  }

  Future<void> addToSenderContacts(String? senderId, String? receiverId, currentTime) async {
    DocumentSnapshot senderSnapshot = await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      ContactModel receiverContact = ContactModel(
        uid: receiverId,
        addedOn: currentTime,
      );

      await getContactsDocument(of: senderId, forContact: receiverId).set(receiverContact.toJson());
    }
  }

  Future<void> addToReceiverContacts(String? senderId, String? receiverId, currentTime) async {
    DocumentSnapshot receiverSnapshot = await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      ContactModel senderContact = ContactModel(
        uid: senderId,
        addedOn: currentTime,
      );

      await getContactsDocument(of: receiverId, forContact: senderId).set(senderContact.toJson());
    }
  }

  //Fetch User List

  Stream<QuerySnapshot> fetchContacts({String? userId}) {
    return userRef.doc(userId).collection(CONTACT_COLLECTION).orderBy("lastMessageTime", descending: true).snapshots();
  }

  Stream<List<UserModel>> getUserDetailsById({String? id, String? searchText}) {
    return userRef
        .where("uid", isEqualTo: id)
        .where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase())
        .snapshots()
        .map((event) => event.docs.map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Stream<QuerySnapshot> fetchLastMessageBetween({required String senderId, required String receiverId}) {
    return ref!.doc(senderId).collection(receiverId).orderBy("createdAt", descending: false).snapshots();
  }

  Future<void> clearAllMessages({String? senderId, required String receiverId}) async {
    final WriteBatch _batch = fireStore.batch();

    ref!.doc(senderId).collection(receiverId).get().then((value) async {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });

      return _batch.commit();
    }).catchError(log);
  }

  Future<void> deleteChat({String? senderId, required String receiverId}) async {
    final WriteBatch _batch = fireStore.batch();
    await ref!.doc(senderId).collection(receiverId).get().then((value) {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });
    userRef.doc(senderId).collection(CONTACT_COLLECTION).doc(receiverId).delete();

    return await _batch.commit();
  }

  Future<void> deleteSingleMessage({String? senderId, required String receiverId, String? documentId}) async {
    try {
      ref!.doc(senderId).collection(receiverId).doc(documentId).delete();
    } on Exception catch (e) {
      log(e);
      throw 'Something went wrong';
    }
  }

  Future<void> setUnReadStatusToTrue({required String senderId, required String receiverId, String? documentId}) async {
    if (!(senderId == getStringAsync(userId))) {
      ref!.doc(senderId).collection(receiverId).where('isMessageRead', isEqualTo: false).get().then((value) {
        value.docs.forEach((element) {
          element.reference.update({
            'isMessageRead': true,
          });
        });
      });
    } else {
      ref!.doc(receiverId).collection(senderId).where('isMessageRead', isEqualTo: false).get().then((value) {
        value.docs.forEach((element) {
          element.reference.update({
            'isMessageRead': true,
          });
        });
      });
    }
  }

  Stream<int> getUnReadCount({String? senderId, required String receiverId, String? documentId}) {
    if (!(senderId == getStringAsync(userId))) {
      return ref!
          .doc(senderId)
          .collection(receiverId)
          .where('isMessageRead', isEqualTo: false)
          .where('receiverId', isEqualTo: senderId)
          .snapshots()
          .map(
            (event) => event.docs.length,
          )
          .handleError((e) => 0);
    }
    return ref!
        .doc(receiverId)
        .collection(senderId!)
        .where('isMessageRead', isEqualTo: false)
        .where('receiverId', isEqualTo: senderId)
        .snapshots()
        .map(
          (event) => event.docs.length,
        )
        .handleError((e) => 0);
  }
}

String dummyContent = "11a1215l0119a140409p0919";


encryptData(String contentData) {
  // encrypt algoritham
  final key = encrypt.Key.fromUtf8(dummyContent);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  // encript file data to base64
  final encrypted = encrypter.encrypt(contentData, iv: iv);
  String encryptedData = encrypted.base64;

  return encryptedData;
}

decryptedData(String encryptedData) {
  final key = encrypt.Key.fromUtf8(dummyContent);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  String decrypted =
  encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: iv);

  return decrypted;
}



