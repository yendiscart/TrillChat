import '../../components/UserProfileImageDialog.dart';
import '../../main.dart';
import '../../models/ChatRequestModel.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../screens/PickupLayout.dart';
import '../../utils/AppColors.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ChatRequestScreen extends StatefulWidget {
  @override
  _ChatRequestScreenState createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        appBar: appBarWidget("Chat Request", textColor: Colors.white),
        body: StreamBuilder<List<ChatRequestModel>>(
            stream: chatRequestService.getChatRequestList(),
            builder: (context, snap) {
              if (snap.hasData) {
                return snap.data!.isNotEmpty
                    ? ListView.builder(
                        itemCount: snap.data!.length,
                        padding: EdgeInsets.only(top: 16),
                        itemBuilder: (context, index) {
                          ChatRequestModel? data = snap.data![index];
                          return FutureBuilder<UserModel?>(
                            future: getUser(data.senderIdRef!),
                            builder: (context, value) {
                              //after handling response uncomment this line
                              // UserModel val = UserModel.fromJson(value as Map<String, dynamic>);
                              final AsyncSnapshot<UserModel?>? val = value as dynamic;
                              log(val);

                              if (val!.hasError) {
                                return Text(val.error.toString(), style: primaryTextStyle());
                              } else {
                                if (val.hasData && val.data != null) {
                                  return SettingItemWidget(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    leading: val.data!.photoUrl!.isEmpty
                                        ? Container(
                                            height: 50,
                                            width: 50,
                                            padding: EdgeInsets.all(10),
                                            color: primaryColor,
                                            child: Text(val.data!.name.validate()[0].capitalizeFirstLetter(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                                          ).cornerRadiusWithClipRRect(50).onTap(() {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return UserProfileImageDialog(data: val.data);
                                              },
                                            );
                                          })
                                        : Hero(
                                            tag: val.data!.uid.validate(),
                                            child: cachedImage(val.data!.photoUrl.validate(), height: 50, width: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                                          ).onTap(() {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return UserProfileImageDialog(data: val.data);
                                              },
                                            );
                                          }),
                                    title: val.data!.name.validate(),
                                    // subTitle: data.createdAt!.toDate().timeAgo,
                                    onTap: () async {
                                      ChatScreen(val.data!).launch(context);
                                    },
                                  );
                                }
                              }
                              return snapWidgetHelper(val, loadingWidget: Offstage());
                            },
                          );
                        },
                      )
                    : noDataFound().center();
              }
              return snapWidgetHelper(
                snap,
                loadingWidget: Loader(),
                errorWidget: SizedBox().center(),
              );
            }),
      ),
    );
  }

  Future<UserModel?> getUser(DocumentReference data) async {
    return await data.get().then((value) => UserModel.fromJson(value.data() as Map<String, dynamic>)).catchError((e) {
      log(e);
    });
  }
}
