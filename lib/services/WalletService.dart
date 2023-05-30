import 'package:chat/services/BaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../utils/AppConstants.dart';

class WalletService extends BaseService{

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  WalletService(){
    ref = fireStore.collection(USER_COLLECTION);
  }

}