import '../../components/FullScreenImageWidget.dart';
import '../../components/Permissions.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/CallFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;

  UserProfileScreen({required this.uid});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserModel currentUser;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isBlocked = await userService.userByEmail(getStringAsync(userEmail)).then((value) => value.blockedTo!.contains(userService.ref!.doc(widget.uid)));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildImageIconWidget({double? height, double? width, double? roundRadius}) {
    if (currentUser.photoUrl.validate().isNotEmpty) {
      return cachedImage(currentUser.photoUrl.validate(), radius: 50, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
        FullScreenImageWidget(
          photoUrl: currentUser.photoUrl.validate(),
          isFromChat: true,
          name: currentUser.name.validate(),
        ).launch(context);
      });
    }
    return noProfileImageFound(height: 100, width: 100).onTap(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<UserModel>(
        stream: userService.singleUser(widget.uid),
        builder: (context, snap) {
          if (snap.hasData) {
            currentUser = snap.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 310.0,
                  backgroundColor: context.scaffoldBackgroundColor,
                  floating: true,
                  pinned: false,
                  snap: false,
                  stretch: true,
                  leading: BackButton(color: textPrimaryColorGlobal).onTap(() {
                    finish(context);
                  }),
                  stretchTriggerOffset: 120.0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    stretchModes: [StretchMode.zoomBackground],
                    titlePadding: EdgeInsetsDirectional.only(start: 50.0, bottom: 20.0),
                    background: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          32.height,
                          buildImageIconWidget(),
                          aboutDetail(),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Container(
                        height: context.height(),
                        color: context.scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            statusWidget(),
                            _buildBlockMSG(),
                            _buildReport(),
                          ],
                        ),
                      ),
                    );
                  }, childCount: 1),
                ),
              ],
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }

  Widget aboutDetail() {
    return Container(
      color: context.cardColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: context.width(),
      child: Column(
        children: [
          16.height,
          Text("${currentUser.name}", style: boldTextStyle(letterSpacing: 0.5)),
          8.height,
          Text(currentUser.phoneNumber.validate().substring(0, currentUser.phoneNumber!.length - 3) + "***", style: secondaryTextStyle()),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.message, color: primaryColor),
                    onPressed: () {
                      finish(context);
                    },
                  ),
                  Text("Message", style: boldTextStyle(size: 12, letterSpacing: 0.5, color: primaryColor)),
                ],
              ),
              16.width,
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.call, color: primaryColor),
                    onPressed: () async {
                      if (await userService.isUserBlocked(currentUser.uid.validate())) {
                        unblockDialog(context, receiver: currentUser);
                        return;
                      }
                      return await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? CallFunctions.voiceDial(
                              context: context,
                              from: sender,
                              to: currentUser,
                            )
                          : {};
                    },
                  ),
                  Text("Call", style: boldTextStyle(size: 12, letterSpacing: 0.5, color: primaryColor)),
                ],
              ),
              16.width,
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.videocam, color: primaryColor),
                    onPressed: () async {
                      if (await userService.isUserBlocked(currentUser.uid.validate())) {
                        unblockDialog(context, receiver: currentUser);
                        return;
                      }
                      return await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? CallFunctions.dial(
                              context: context,
                              from: sender,
                              to: currentUser,
                            )
                          : {};
                    },
                  ),
                  Text("Video Call", style: boldTextStyle(size: 12, letterSpacing: 0.5, color: primaryColor)),
                ],
              ),
            ],
          ),
          16.height,
        ],
      ),
    );
  }

  Widget statusWidget() {
    return Container(
      color: context.cardColor,
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      width: context.width(),
      child: SettingItemWidget(
        title: currentUser.userStatus.validate(),
        titleTextStyle: primaryTextStyle(),
        padding: EdgeInsets.all(0),
        subTitle: currentUser.updatedAt!.toDate().timeAgo,
      ),
    );
  }

  void blockMessage() async {
    List<DocumentReference> temp = [];
    await userService.userByEmail(getStringAsync(userEmail)).then((value) {
      temp = value.blockedTo!;
    });
    if (!temp.contains(userService.ref!.doc(widget.uid))) {
      temp.add(userService.getUserReference(uid: currentUser.uid.validate()));
    }

    userService.blockUser({"blockedTo": temp}).then((value) {
      finish(context);
      finish(context);
      finish(context);
    }).catchError((e) {
      //
    });
  }

  Widget _buildBlockMSG() {
    return SettingItemWidget(
      decoration: BoxDecoration(color: context.cardColor),
      title: isBlocked ? "${"Unblock".translate}${' ' + currentUser.name.validate()}" : "${"block".translate}${' ' + currentUser.name.validate()}",
      leading: Icon(Icons.block, color: Colors.red[800]),
      titleTextStyle: primaryTextStyle(color: Colors.red[800]),
      onTap: () {
        if (isBlocked) {
          unblockDialog(context, receiver: currentUser);
        } else {
          showInDialog(
            context,
            dialogAnimation: DialogAnimation.SCALE,
            title: Text(
              "${"block".translate}" + " ${currentUser.name.validate()}? " + "blocked_contact_will_no_longer_be_able_to_call_you_or_send_you_message".translate,
              style: primaryTextStyle(),
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  finish(context);
                },
                child: Text(
                  "cancel".translate,
                  style: TextStyle(color: textSecondaryColorGlobal),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    blockMessage();
                  },
                  child: Text("block".translate.toUpperCase(), style: TextStyle(color: secondaryColor))),
            ],
          );
        }
      },
    );
  }

  void reportBy() async {
    List<DocumentReference> temp = [];
    temp = await userService.userByEmail(currentUser.email).then((value) => value.reportedBy!);
    if (!temp.contains(userService.ref!.doc(getStringAsync(userId)))) {
      temp.add(userService.getUserReference(uid: getStringAsync(userId)));
    }

    if (temp.length >= appSettingStore.mReportCount) {
      userService.reportUser({"isActive": false}, currentUser.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast("${"UserAccountIsDeactivatedByAdminToRestorePleaseContactAdmin".translate}");
        toast(value.toString());
      }).catchError((e) {
        //
      });
    } else {
      userService.reportUser({"reportedBy": temp}, currentUser.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast(value.toString());
      }).catchError((e) {
        //
      });
    }
  }

  Widget _buildReport() {
    return SettingItemWidget(
      title: "report_contact".translate,
      decoration: BoxDecoration(color: context.cardColor),
      leading: Icon(Icons.thumb_down, color: Colors.red[800]),
      titleTextStyle: primaryTextStyle(color: Colors.red[800]),
      onTap: () {
        showInDialog(
          context,
          dialogAnimation: DialogAnimation.SCALE,
          title: Text("${"report".translate} ${currentUser.name.validate()} ?", style: primaryTextStyle()),
          actions: [
            TextButton(
              onPressed: () {
                finish(context);
              },
              child: Text(
                "cancel".translate,
                style: TextStyle(color: textSecondaryColorGlobal),
              ),
            ),
            TextButton(
              onPressed: () async {
                reportBy();
              },
              child: Text(
                "report".translate.toUpperCase(),
                style: TextStyle(color: secondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
