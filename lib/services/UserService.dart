import 'dart:io';

import 'package:chat/models/TransactionModel.dart';
import 'package:file_picker/file_picker.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

import '../models/ChatMessageModel.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }

  Future<void> updateUserInfo(Map data, String id, {File? profileImage}) async {
    if (profileImage != null) {
      String fileName = basename(profileImage.path);
      Reference storageRef = _storage.ref().child("$USER_PROFILE_IMAGE/$fileName");
      UploadTask uploadTask = storageRef.putFile(profileImage);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) {
          loginStore.setPhotoUrl(aPhotoUrl: value);
          data.putIfAbsent("photoUrl", () => value);
        });
      });
    }

    return ref!.doc(id).update(data as Map<String, Object?>);
  }

  Future<void> updateUserStatus(Map data, String id) async {
    return ref!.doc(id).update(data as Map<String, Object?>);
  }

  Future<void> updateBalance(double balance, String id) async {

    var currentBalance=await getUserById(val: id);
    var newBalance=0.0;
    if(currentBalance.balance!=null){
      newBalance=currentBalance.balance!+balance;
    }else{
      newBalance=currentBalance.balance!;
    }
    Map<String,dynamic> presenceStatusTrue = {
      'balance': newBalance,
    };

    return ref!.doc(id).update(presenceStatusTrue as Map<String, Object?>);
  }

  Future<String> transferBalance(double amount, String senderId, String receiverId) async {
    // Get the sender's current balance
    if (senderId== receiverId) {
      // Handle the case where the sender doesn't have enough balance
      print('Same User');
      return 'Transfer failed';
    }
    var sender = await getUserById(val: senderId);

    if (sender.balance == null) {
      // Handle the case where the sender doesn't have a balance
      print('Sender has no balance');
      return 'Has no balance';
    }

    // Check if the sender has enough balance to transfer
    if (sender.balance! < amount) {
      // Handle the case where the sender doesn't have enough balance
      print('Insufficient balance');
      return 'Insufficient balance';
    }

    // Get the receiver's current balance
    var receiver = await getUserById(val: receiverId);

    if (receiver.balance == null) {
      // Handle the case where the receiver doesn't have a balance
      print('Receiver has no balance');
      receiver.balance=0.0;
    }
    // Update the balances
    // var senderNewBalance = sender.balance! - amount;

    // var receiverNewBalance = receiver.balance! + amount;

    // Update the sender's balance
    await updateBalance(-amount, senderId);

    // Update the receiver's balance
    await updateBalance(amount, receiverId);

    // Print the updated balances
    await chatMessage(sender, receiver, amount);
    return 'Transfer success';
  }

  Future<UserModel> getUser({String? email}) {
    return ref!.where("email", isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.length == 1) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'User Not found';
      }
    });
  }

  Future<UserModel> getUserById({String? val}) {
    return ref!.where("uid", isEqualTo: val).limit(1).get().then((value) {
      if (value.docs.length == 1) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'User Not found';
      }
    });
  }

  Stream<List<UserModel>> users({String? searchText}) {
    return ref!.where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return UserModel.fromJson(y.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<UserModel> userByEmail(String? email) async {
    return await ref!.where('email', isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'No User Found';
      }
    });
  }

  Stream<UserModel> singleUser(String? id, {String? searchText}) {
    return ref!.where('uid', isEqualTo: id).limit(1).snapshots().map((event) {
      return UserModel.fromJson(event.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserModel> userByMobileNumber(String? phone) async {
    return await ref!.where('phoneNumber', isEqualTo: phone).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw EXCEPTION_NO_USER_FOUND;
      }
    });
  }

  bool getPreviouslyChat(String uid) {
    return messageRequestStore.userContactList.where((element) => element.uid == uid).length != 0;
  }

  Future<String> blockUser(Map<String, dynamic> data) async {
    return await ref!.doc(getStringAsync(userId)).update(data).then((value) {
      return "User Blocked";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  Future<String> unBlockUser(Map<String, dynamic> data) async {
    return await ref!.doc(getStringAsync(userId)).update(data).then((value) {
      return "User Blocked";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  Future<String> reportUser(Map<String, dynamic> data, String reportUserId) async {
    return await ref!.doc(reportUserId).update(data).then((value) {
      return "Account Reported to Mighty Chat";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  DocumentReference getUserReference({required String uid}) {
    return userService.ref!.doc(uid);
  }

  Future<void> removeDocument(String? id) => userService.ref!.doc(id).delete();

  Future<bool> isUserBlocked(String uid) async {
    return await userService.userByEmail(getStringAsync(userEmail)).then((value) {
      return value.blockedTo!.contains(getUserReference(uid: uid));
    });
  }


  Future<String> chatMessage(UserModel? sender,UserModel? receiverUser,double? amount) async{
    ChatMessageModel data=new ChatMessageModel();
    data.receiverId = receiverUser!.uid;
    data.senderId = sender!.uid;
    data.message ='${amount.toString()}';
    data.isMessageRead = false;
    data.stickerPath = '';
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.isEncrypt = false;
    data.messageType=MessageType.TRANSACTION.name;
    await chatMessageService.addMessage(data).then((value) async {

        // ignore: unnecessary_null_comparison
        await chatMessageService
            .addMessageToDb(senderDoc: value, data: data, sender: sender, user: receiverUser, isRequest: false)
            .then((value) {
          //
        });
    });
    return 'ok';
  }
}
