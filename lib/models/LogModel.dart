class LogModel {
  int? logId;
  String? callerName;
  String? callerPic;
  String? receiverName;
  String? receiverPic;
  String? callStatus;
  String? callType;
  String? timestamp;
  bool? isVerifiedCaller;
  bool? isVerifiedReceiver;

  LogModel({
    this.logId,
    this.callerName,
    this.callerPic,
    this.receiverName,
    this.receiverPic,
    this.callStatus,
    this.callType,
    this.timestamp,
    this.isVerifiedCaller,
    this.isVerifiedReceiver,
  });
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      logId: json['log_id'],
      callerName: json['caller_name'],
      callerPic: json['caller_pic'],
      receiverName: json['receiver_name'],
      receiverPic: json['receiver_pic'],
      callType: json['callType'],
      callStatus: json['call_status'],
      timestamp: json['timestamp'],
      isVerifiedCaller: json['isVerifiedCaller']==1?true:false,
      isVerifiedReceiver: json['isVerifiedReceiver']==1?true:false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['log_id'] = this.logId;
    data['caller_name'] = this.callerName;
    data['caller_pic'] = this.callerPic;
    data['receiver_name'] = this.receiverName;
    data['receiver_pic'] = this.receiverPic;
    data['call_status'] = this.callStatus;
    data['timestamp'] = this.timestamp;
    data['callType'] = this.callType;
    data['isVerifiedReceiver'] = this.isVerifiedReceiver! ? 1 : 0;
    data['isVerifiedCaller'] = this.isVerifiedCaller!?1:0;

    return data;
  }
}
// to map
