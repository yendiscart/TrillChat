import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  String? uid;
  String? transactionType;
  String? from;
  String? to;
  String? status;
  double? amount;
  String? email;
  String? reason;
  Timestamp? createAt;
  Timestamp? updatedAt;


  TransactionModel({
      this.id,
      this.uid,
      this.transactionType,
      this.from,
      this.to,
      this.status,
      this.amount,
      this.email,
      this.reason,
      this.createAt,
      this.updatedAt});

  factory TransactionModel.fromJson (dynamic json){
    return TransactionModel(
      id : json['id'],
      uid: json['uid'],
      transactionType: json['transactionType'],
      from: json['from'],
      to: json['to'],
      status: json['status'],
      amount: json['amount']??double.parse(json['amount']),
      email: json['email'],
      reason: json['reason'],
      createAt: json['createAt'],
      updatedAt: json['updatedAt'],
    );

  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['uid'] = uid;
    map['transactionType'] = transactionType;
    map['id'] = id;
    map['from'] = from;
    map['to'] = to;
    map['status'] = status;
    map['amount'] = amount;
    map['email'] = email;
    map['reason']=reason;
    map['createAt']=createAt??new Timestamp.now();
    map['updatedAt']=updatedAt??new Timestamp.now();
    return map;
  }
}
