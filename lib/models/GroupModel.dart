class GroupModel {
  String? createdBy;
  DateTime? createdOn;
  String? descriptionId;
  String? fltrdId;
  String isTypingID;
  int? latestTimeStamp;
  List<String>? membersList;
  String? name;
  String photoUrl;
  String? groupType;
  bool isEncrypt;

  GroupModel({
    this.createdBy,
    this.createdOn,
    this.descriptionId,
    this.fltrdId,
    this.isTypingID='',
    this.latestTimeStamp,
    this.membersList,
    this.name,
    this.photoUrl='',
    this.groupType,
    this.isEncrypt=false,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      createdBy: json['createdBy'],
      createdOn: json['createdOn'],
      descriptionId: json['descriptionId'],
      fltrdId: json['fltrdId'],
      isTypingID: json['isTypingID'],
      latestTimeStamp: json['latestTimeStamp'],
      membersList : json['membersList'] != null ? json['membersList'].cast<String>() : [],
      name: json['name'],
      photoUrl: json['photoUrl'],
      groupType: json['groupType'],
      isEncrypt:json['isEncrypt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['descriptionId'] = this.descriptionId;
    data['fltrdId'] = this.fltrdId;
    data['isTypingID'] = this.isTypingID;
    data['latestTimeStamp'] = this.latestTimeStamp;
    data['membersList'] = this.membersList;
    data['name'] = this.name;
    data['photoUrl'] = this.photoUrl;
    data['groupType'] = this.groupType;
    data['isEncrypt'] = this.isEncrypt;
    return data;
  }
}
