import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? name;
  String? email;
  String? photoUrl;
  String? userStatus;
  String? deviceId;
  bool? isPresence;
  List<String>? caseSearch;
  String? phoneNumber;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  int? lastSeen;
  bool? isEmailLogin;
  String? oneSignalPlayerId;
  bool? isActive;
  bool? isVerified;
  int? reportUserCount;
  List<DocumentReference>? blockedTo;
  List<DocumentReference>? reportedBy;
  double? balance;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.userStatus,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
    this.isEmailLogin,
    this.caseSearch,
    this.isPresence,
    this.lastSeen,
    this.isVerified,
    this.oneSignalPlayerId,
    this.blockedTo,
    this.reportedBy,
    this.isActive,
    this.reportUserCount,
    this.deviceId,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      userStatus: json['userStatus'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isEmailLogin: json['isEmailLogin'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isPresence: json['isPresence'],
      isActive: json['isActive'],
      isVerified: json['isVerified'],
      reportUserCount: json['reportUserCount'],
      lastSeen: json['lastSeen'],
      oneSignalPlayerId: json['oneSignalPlayerId'],
      deviceId: json['deviceId'],
      caseSearch: json['caseSearch'] != null ? List<String>.from(json['caseSearch']) : [],
      blockedTo: json['blockedTo'] != null ? List<DocumentReference>.from(json['blockedTo']) : [],
      reportedBy: json['reportedBy'] != null ? List<DocumentReference>.from(json['reportedBy']) : [],
      balance: json['balance'] != null ? (json['balance'] is int ? (json['balance'] as int).toDouble() : json['balance'] as double) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['email'] = this.email;
    data['userStatus'] = this.userStatus;
    data['phoneNumber'] = this.phoneNumber;
    data['photoUrl'] = this.photoUrl;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['isEmailLogin'] = this.isEmailLogin;
    data['isActive'] = this.isActive;
    data['isVerified'] = this.isVerified;
    data['caseSearch'] = this.caseSearch;
    data['blockedTo'] = this.blockedTo;
    data['reportedBy'] = this.reportedBy;
    data['isPresence'] = this.isPresence;
    data['reportUserCount'] = this.reportUserCount;
    data['lastSeen'] = this.lastSeen;
    data['oneSignalPlayerId'] = this.oneSignalPlayerId;
    data['deviceId'] = this.deviceId;
    data['balance'] = this.balance;

    return data;
  }

}
