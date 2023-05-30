import 'package:chat/main.dart';
import 'package:chat/models/TransactionModel.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/services/BaseService.dart';
import 'package:chat/services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/AppConstants.dart';
class PayOutService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  PayOutService() {
    ref = fireStore.collection(TRANSACTION_COLLECTION);
  }
  Future<void> initiatePayout() async {
    try {
      // Create a payment method for the payout
      PaymentMethod paymentMethod = await Stripe.instance.createPaymentMethod(
        PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: 'user@example.com', // Set the desired email address
              ),
            )
        ),
      );

      // Create a payout object
      Map<String, dynamic> payoutData = {
        'amount': 1000, // Amount in cents
        'currency': 'usd',
        'destination': 'ACCOUNT_ID', // ID of the destination account
        'payment_method': paymentMethod.id,
      };

      // Send the payout request
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payouts'),
        headers: {
          'Authorization': 'Bearer YOUR_SECRET_API_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: payoutData,
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Payout successful
        print('Payout successful');
      } else {
        // Payout failed
        print('Payout failed: ${response.body}');
      }
    } catch (error) {
      // Handle errors
      print('Error initiating payout: $error');
    }
  }

  Future<TransactionModel> confirmPayout(TransactionModel data) async {
    await UserService().updateBalance(-data.amount!, data.uid!);
    var doc = await ref!.add(data.toJson());
    doc.update({'id': doc.id});

    // Retrieve the document snapshot
    var snapshot = await doc.get();

    // Map the snapshot data to TransactionModel using fromJson factory method
    var transactionModel = TransactionModel.fromJson(snapshot.data());

    return transactionModel;

  }

  Stream<QuerySnapshot> fetchTransaction({String? userId,String? status}) {
    if(getStringAsync(userEmail)==adminEmail){
      if(status!=null){
        return ref!.where("status",isEqualTo: status).snapshots();
      }else{
        return ref!.snapshots();
      }
    }else{
      if(status!=null){
        // print("user id "+userId!);
        return ref!.where("status",isEqualTo: status)
            .where("uid", isEqualTo: userId)
            .snapshots();
      }else{
        return ref!.where("uid",isEqualTo: userId).snapshots();
      }
    }


  }

  Future<TransactionModel> updateTransaction(TransactionModel data) async {
    if (data.status == "REJECT") {
      await UserService().updateBalance(data.amount!, data.from!);
    }

// Retrieve the document reference based on the transaction ID
    var docRef = ref!.doc(data.id);

    // Update the document data with the new status
    await docRef.update({'status': data.status});

    // Retrieve the updated document snapshot
    var snapshot = await docRef.get();

    // Map the snapshot data to TransactionModel using fromJson factory method
    var transactionModel = TransactionModel.fromJson(snapshot.data());
    UserModel receiver=await UserService().getUserById(val: transactionModel.uid);

    if (!receiver.oneSignalPlayerId.isEmptyOrNull) {
      notificationService.sendPushNotifications('Transaction update ', 'You transaction '+transactionModel.id.toString()+' has '+transactionModel.status.toString()
          , receiverPlayerId: receiver.oneSignalPlayerId).catchError(log);
    }

    return transactionModel;

  }
}