import 'dart:io';
import '../../models/ChatMessageModel.dart';
import '../../models/GroupModel.dart';
import '../../models/UserModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

class GroupChatMessageService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  late CollectionReference userRef;

  GroupChatMessageService() {
    userRef = fireStore.collection(USER_COLLECTION);
  }

  addGroup(GroupModel data, DateTime time) async {
    await fireStore.collection('groups').doc(getStringAsync(userId).toString() + '--' + time.millisecondsSinceEpoch.toString()).set(data.toJson());
  }

  getGroupChat({String? groupChatId}) {
    return fireStore.collection(GROUP_COLLECTION).doc(groupChatId).collection(GROUP_CHATS).orderBy('createdAt').snapshots();
  }

  Future<DocumentReference> addMessage(ChatMessageModel data, String docId) async {
    var doc = await fireStore.collection(GROUP_COLLECTION).doc(docId).collection(GROUP_CHATS).add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Query chatMessagesWithPagination({String? currentUserId, required String groupDocId}) {
    return fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).orderBy('createdAt', descending: true);
  }

  Future<void> addMessageToDb({required DocumentReference senderDoc, ChatMessageModel? data, UserModel? sender, UserModel? user, File? image, bool isRequest = false}) async {
    String imageUrl = '';

    if (image != null) {
      String fileName = basename(image.path);
      Reference storageRef = _storage.ref().child("$GROUP_PROFILE_IMAGES/${getStringAsync(userId)}/$fileName");
      UploadTask uploadTask = storageRef.putFile(image);

      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;
          log(imageUrl);
          // fileList.removeWhere((element) => element.id == senderDoc.id);
        }).catchError((e) {
          toast(e.toString());
        });
      }).catchError((e) {
        toast(e.toString());
      });
    }
    userRef.doc(getStringAsync(userId)).update({"lastMessageTime": DateTime.now().millisecondsSinceEpoch});
    updateChatDocument(senderDoc, image: image, imageUrl: imageUrl);
  }

  // ignore: body_might_complete_normally_nullable
  DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
    Map<String, dynamic> sendData = {'id': data.id};

    if (image != null) {
      sendData.putIfAbsent('photoUrl', () => imageUrl);
    }
    data.update(sendData);
  }



  addLatLong(ChatMessageModel data, {String? lat, String? long, String? groupId}) {
    Map<String, dynamic> sendData = {'id': data.id};
    fireStore.collection(GROUP_COLLECTION).doc(groupId).collection(GROUP_CHATS).doc(data.id).set({'currentLat': lat, 'currentLong': long}, SetOptions(merge: true)).then((value) {
      //
    });

    sendData.putIfAbsent('current_lat', () => lat);
    sendData.putIfAbsent('current_lat', () => long);
  }

  addIsEncrypt(ChatMessageModel data) {
    Map<String, dynamic> sendData = {'id': data.id};
    sendData.putIfAbsent("isEncrypt", () => true);
  }

  Future<void> deleteGrpSingleMessage({String? groupDocId, String? messageDocId}) async {
    try {
      log("here");
      fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).doc(messageDocId).delete();
      log("done----------------");
    } on Exception catch (e) {
      log(e);
      throw 'Something went wrong';
    }
  }

  Future<void> clearAllMessages({String? groupDocId}) async {
    final WriteBatch _batch = fireStore.batch();

    fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).get()
   .then((value) async {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });

      return _batch.commit();
    }).catchError(log);
  }

  Future<void> deleteChat({String? groupDocId}) async {
    final WriteBatch _batch = fireStore.batch();
    await fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).get().then((value) {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });
    fireStore.collection(GROUP_COLLECTION).doc(groupDocId).delete();

    return await _batch.commit();
  }

  Stream<QuerySnapshot<Object?>> fetchLastMessageBetween({required String groupDocId})  {
    return fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).orderBy('createdAt', descending: false).snapshots();
  }


}
