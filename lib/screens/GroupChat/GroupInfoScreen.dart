import 'dart:io';
import '../../components/FullScreenImageWidget.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../screens/GroupChat/ChangeSubjectScreen.dart';
import '../../screens/GroupChat/NewGroupScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart' as path;

class GroupInfoScreen extends StatefulWidget {
  final String groupId, groupName;
  final dynamic data;

  GroupInfoScreen({required this.groupId, required this.groupName, this.data});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  List membersList = [];
  List<UserModel> userModelList = [];
  bool isLoading = true;
  bool isProfileChange = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  PickedFile? image;

  String admin = '';
  String? groupName;
  String? imageUrl;
  bool isAdmin = false;

  bool isChangeAdmin = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore.collection('groups').doc(widget.groupId).get().then((chatMap) {
      admin = chatMap['createdby'];
      membersList = chatMap['memberslist'];
      checkAdmin();
      groupName = chatMap['name'];
      imageUrl = chatMap['photourl'];

      getMemberList();
      isLoading = false;
      setState(() {});
    });
  }

  getMemberList() {
    userModelList.clear();
    membersList.forEach((element) async {
      UserModel userm = await userService.getUserById(val: element);
      userModelList.add(userm);
      setState(() {});
    });
  }

  void checkAdmin() {
    if (getStringAsync(userId) == admin) {
      isAdmin = true;
      log('isAdmin');
      log(isAdmin);
      setState(() {});
    } else {
      userService.singleUser(admin).first.then((value) => log("success")).catchError((e) {
        if (counter == 0) {
          isChangeAdmin = true;
          setState(() {});
          removeMembers(0, admin);
        }
      });
    }
    // return isAdmin;
  }

  Future removeMembers(int index, String? uid) async {
    List newMembers = [];

    setState(() {
      isLoading = true;
      membersList.map((e) {
        if (e.toString().contains(uid.toString())) {
        } else {
          newMembers.add(e);
        }
      }).toList();
    });

    await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).update({"memberslist": newMembers, "createdby": isChangeAdmin ? newMembers[0] : admin}).then((value) async {
      await _firestore.collection('users').doc(widget.data['uid']).collection('groups').doc(widget.groupId).delete();
      counter = 1;
      setState(() {});
      getGroupDetails();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    finish(context);
                    ChatScreen(userModelList[index]).launch(context);
                  },
                  title: Text("Message ${userModelList[index].name}"),
                ),
                if (isAdmin)
                  ListTile(
                    onTap: () {
                      finish(context);
                      removeMembers(index, userModelList[index].uid);
                    },
                    title: Text("Remove ${userModelList[index].name}"),
                  ),
              ],
            ),
          );
        });
  }

  Future onLeaveGroup() async {
    if (isAdmin == false) {
      bool? res = await showConfirmDialog(context, 'lblLeave'.translate + ' ${widget.groupName} ' + 'lblgroup'.translate + '?', buttonColor: secondaryColor);
      if (res ?? false) {
        setState(() {
          isLoading = true;
        });

        for (int i = 0; i < membersList.length; i++) {
          if (membersList[i] == _auth.currentUser!.uid) {
            membersList.removeAt(i);
          }
        }
        await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).update({
          "memberslist": membersList,
        });

        finish(context);
        finish(context);
      }
    } else {
      toast('lblAdmincantLeavegroup'.translate);
    }
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    image = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 100);
    updateGroupProfileImg(profileImage: File(image!.path));
    setState(() {});
  }

  Future<void> updateGroupProfileImg({File? profileImage}) async {
    appStore.isLoading = true;
    if (profileImage != null) {
      String fileName = path.basename(profileImage.path);
      Reference storageRef = FirebaseStorage.instance.ref().child("$GROUP_PROFILE_IMAGE/$fileName");
      UploadTask uploadTask = storageRef.putFile(profileImage);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;
          await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).update({
            "photourl": imageUrl,
          });
          isProfileChange = true;
          setState(() {});
          getGroupDetails();
          appStore.isLoading = false;
        });
      });
    }
  }

  Widget profileImage() {
    if (image != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(File(image!.path), height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(50).onTap(() {
            getImage();
          }),
          Loader(color: secondaryColor).visible(appStore.isLoading)
        ],
      );
    } else if (imageUrl != null) {
      return cachedImage(imageUrl, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
        FullScreenImageWidget(
          photoUrl: imageUrl,
          isFromChat: true,
          name: widget.groupName,
        ).launch(context);
      });
    } else {
      return noProfileImageFound(height: 100, width: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        finish(context, isProfileChange);
        return Future.value(false);
        //
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 230.0,
                  backgroundColor: context.scaffoldBackgroundColor,
                  floating: true,
                  pinned: false,
                  snap: false,
                  stretch: true,
                  actions: [
                    SizedBox(
                      // width: 32,
                      child: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: textPrimaryColorGlobal),
                        color: context.cardColor,
                        onSelected: (value) async {
                          // if (getStringAsync(USER_EMAIL) != demoUser) {
                          if (value == 1) {
                            bool? res = await ChangeSubjectScreen(groupName: widget.groupName, groupId: widget.groupId).launch(context);
                            if (res ?? true) {
                              getGroupDetails();
                              setState(() {});
                            }
                          } else if (value == 2) {
                            getImage();
                          }
                        },
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('lblChangesubject'.translate, style: secondaryTextStyle()),
                            value: 1,
                          ),
                          PopupMenuItem(
                            child: Text('lblChangeGroupProfile'.translate, style: secondaryTextStyle()),
                            value: 2,
                          )
                        ],
                      ),
                    ),
                  ],
                  leading: BackButton(color: textPrimaryColorGlobal).onTap(() {
                    finish(context, isProfileChange);
                  }),
                  stretchTriggerOffset: 120.0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    stretchModes: [StretchMode.zoomBackground],
                    titlePadding: EdgeInsetsDirectional.only(start: 50.0, bottom: 20.0),
                    // title: Text("'name", style: boldTextStyle(color: Colors.white)),
                    background: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          32.height,
                          profileImage(),
                          8.height,
                          Text(
                            groupName.isEmptyOrNull ? "" : groupName!.validate(),
                            overflow: TextOverflow.ellipsis,
                            style: primaryTextStyle(size: 18),
                          ),
                          4.height,
                          Text(
                            'lblGroup'.translate + ' : ${membersList.length} ' + 'lblMembers'.translate,
                            overflow: TextOverflow.ellipsis,
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${membersList.length} " + 'lblParticipant'.translate, style: secondaryTextStyle()),
                                isAdmin ? 16.height : 0.height,
                                isAdmin
                                    ? InkWell(
                                        onTap: () async {
                                          bool? res = await NewGroupScreen(isAddParticipant: true, groupId: widget.groupId, data: widget.data).launch(context);
                                          if (res ?? true) {
                                            getGroupDetails();
                                            setState(() {});
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 45,
                                              width: 45,
                                              decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor),
                                              child: Icon(Icons.person_add, color: Colors.white.withOpacity(0.9), size: 25),
                                            ),
                                            16.width,
                                            Text('lblAddparticipants'.translate, style: primaryTextStyle())
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                ListView.builder(
                                  itemCount: userModelList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        child: Row(
                                      children: [
                                        userModelList[index].photoUrl!.isEmpty
                                            ? Hero(
                                                tag: userModelList[index].uid.validate(),
                                                child: noProfileImageFound(height: 45, width: 45),
                                              )
                                            : cachedImage(userModelList[index].photoUrl.validate(), width: 45, height: 45, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                                        16.width,
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                               Row(
                                                 children: [
                                                   Text(userModelList[index].uid == getStringAsync(userId) ? 'You' : '${userModelList[index].name.validate().capitalizeFirstLetter()}', style: primaryTextStyle()),
                                                   SizedBox(width: 2.0,),
                                                   Visibility(
                                                     // if visibility is true, the child
                                                     // widget will show otherwise hide
                                                     visible: userModelList[index].isVerified??false,
                                                     child: Icon(
                                                       Icons.verified_rounded,
                                                       color: Colors.blue,
                                                       size: 18,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                                Container(
                                                  decoration: boxDecorationWithRoundedCorners(border: Border.all(color: primaryColor), borderRadius: radius(4)),
                                                  padding: EdgeInsets.all(2),
                                                  child: Text('lblGroupAdmin'.translate, style: primaryTextStyle(size: 10, color: primaryColor)),
                                                ).visible(userModelList[index].uid == admin)
                                              ],
                                            ),
                                            4.height,
                                            Text('${userModelList[index].userStatus.validate()}', style: secondaryTextStyle()),
                                          ],
                                        ).expand(),
                                      ],
                                    ).paddingSymmetric(vertical: 8).onTap(() {
                                      if (userModelList[index].uid != getStringAsync(userId)) {
                                        if (userModelList[index].uid != admin) showDialogBox(index);
                                      }
                                    }));
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            width: context.width(),
                            decoration: boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app, color: Colors.red[800]),
                                8.width,
                                Text(
                                  'lblLeaveGroup'.translate,
                                  style: TextStyle(
                                    fontSize: size.width / 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red[800],
                                  ),
                                ),
                              ],
                            ),
                          ).onTap(() {
                            onLeaveGroup();
                          }),
                          70.height,
                        ],
                      ),
                    );
                  }, childCount: 1),
                )
              ],
            ),
            Loader().center().visible(isLoading)
          ],
        ),
      ),
    );
  }
}
