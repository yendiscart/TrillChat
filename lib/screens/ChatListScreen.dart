import '../../components/ChatOptionDialog.dart';
import '../../components/LastMessageContainer.dart';
import '../../components/UserProfileImageDialog.dart';
import '../../screens/GroupChat/GroupChatRoom.dart';
import '../../main.dart';
import '../../models/ContactModel.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatRequestScreen/ChatRequestScreen.dart';
import '../../screens/DashboardScreen.dart';
import '../../screens/GroupChat/GroupProfileImageDailog.dart';
import '../../screens/NewChatScreen.dart';
import '../../screens/PickupLayout.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'ChatScreen.dart';
import 'package:badges/badges.dart' as badges;

class ChatListScreen extends StatefulWidget {
  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  String id = '';
  bool autoFocus = false;
  String searchCont = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    WidgetsBinding.instance.addObserver(this);

    Map<String, dynamic> presenceStatusTrue = {
      'isPresence': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };

    await userService.updateUserStatus(presenceStatusTrue, getStringAsync(userId));

    id = getStringAsync(userId);

    setState(() {});

    LiveStream().on(SEARCH_KEY, (s) {
      searchCont = s as String;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Stream<List<dynamic>> group({String? searchText}) {
    return fireStore.collection('groups').snapshots().map((x) {
      return x.docs.map((y) {
        return y.data();
      }).toList();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Map<String, dynamic> presenceStatusFalse = {
      'isPresence': false,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };
    if (state == AppLifecycleState.detached) {
      userService.updateUserStatus(presenceStatusFalse, getStringAsync(userId));
    }

    if (state == AppLifecycleState.paused) {
      userService.updateUserStatus(presenceStatusFalse, getStringAsync(userId));
    }
    if (state == AppLifecycleState.resumed) {
      Map<String, dynamic> presenceStatusTrue = {
        'isPresence': true,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      };

      userService.updateUserStatus(presenceStatusTrue, getStringAsync(userId));
    }
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(SEARCH_KEY);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<int>(
                  future: chatRequestService.getRequestLength(),
                  builder: (context, snap) {
                    //chat request
                    if (snap.hasData) {
                      if (snap.data.validate() != -1) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            8.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(MaterialCommunityIcons.chat_alert_outline, color: primaryColor, size: 28),
                                16.width,
                                Text('New Friend Request', style: primaryTextStyle()).expand(),
                                // Text("${snap.data.validate()}", style: boldTextStyle()),
                              ],
                            ).paddingSymmetric(vertical: 8, horizontal: 16).onTap(() {
                              ChatRequestScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                            Divider()
                          ],
                        );
                      } else {
                        return SizedBox();
                      }
                    }
                    return SizedBox();
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: chatMessageService.fetchContacts(userId: getStringAsync(userId)),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text(snapshot.error.toString(), style: boldTextStyle()).center();
                    if (snapshot.hasData) {
                      messageRequestStore.addContactData(
                        data: snapshot.data!.docs.map((e) => ContactModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
                        isClear: true,
                      );

                      if (snapshot.data!.docs == null && snapshot.data!.docs.isEmpty) {
                        return SizedBox(
                          child: noDataFound(),
                          height: context.height() - context.statusBarHeight - kToolbarHeight - 100,
                          width: context.width(),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 0),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            ContactModel contact = ContactModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                            return Column(
                              children: [
                                _builGroupItemWidget(contact: contact).visible(contact.groupRefUrl != null),
                                _buildChatItemWidget(contact: contact),
                              ],
                            );
                          },
                        );
                      }
                    }
                    return snapWidgetHelper(snapshot);
                  },
                ),
                100.height,
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: primaryColor,
          onPressed: () {
            isSearch = false;
            hideKeyboard(context);
            setState(() {});

            NewChatScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 300.milliseconds);
          },
        ),
      ),
    );
  }

  StreamBuilder<List<UserModel>> _buildChatItemWidget({required ContactModel contact}) {
    return StreamBuilder(
      stream: chatMessageService.getUserDetailsById(id: contact.uid, searchText: searchCont),
      builder: (context, snap) {
        if (snap.hasData) {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              UserModel data = snap.data![index];

              if (snap.data!.length == 0) {
                return noDataFound().center();
              }
              return InkWell(
                onTap: () async {
                  if (id != data.uid) {
                    hideKeyboard(context);
                    bool? res = await ChatScreen(data).launch(context);
                    if (res!) {
                      setState(() {});
                      //
                    }
                  }
                },
                onLongPress: () async {
                  await showInDialog(context, builder: (p0) {
                    return ChatOptionDialog(receiverUser: data);
                  }, contentPadding: EdgeInsets.zero, dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      data.photoUrl!.isEmpty
                          ? noProfileImageFound(height: 50, width: 50).cornerRadiusWithClipRRect(50).onTap(() {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return UserProfileImageDialog(data: data);
                                },
                              );
                            })
                          : Hero(
                              tag: data.uid.validate(),
                              child: cachedImage(
                                data.photoUrl.validate(),
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(50),
                            ).onTap(() {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return UserProfileImageDialog(data: data);
                                },
                              );
                            }),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(

                            textDirection: TextDirection.ltr,
                            children: [
                              Text(
                                data.name.validate().capitalizeFirstLetter(),
                                style: primaryTextStyle(size: 18),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 2.0,),
                              Visibility(
                                // if visibility is true, the child
                                // widget will show otherwise hide
                                visible: data.isVerified??false,
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),

                              StreamBuilder<int>(
                                stream: chatMessageService.getUnReadCount(
                                  senderId: getStringAsync(userId),
                                  receiverId: contact.uid.validate(),
                                ),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    if (snap.data != 0) {
                                      return Container(
                                        height: 18,
                                        width: 18,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: secondaryColor),
                                        child: Text(
                                          snap.data.validate().toString(),
                                          style: secondaryTextStyle(size: 12, color: Colors.white),
                                        ).fit().center(),
                                      );
                                    }
                                  }
                                  return Offstage();
                                },
                              ),
                            ],
                          ),
                          2.height,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LastMessageContainer(
                                stream: chatMessageService.fetchLastMessageBetween(senderId: getStringAsync(userId), receiverId: contact.uid!),
                              ),
                            ],
                          ),
                        ],
                      ).expand(),
                    ],
                  ),
                ),
              );
            },
            itemCount: snap.data!.length,
            shrinkWrap: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            dragStartBehavior: DragStartBehavior.start,
          );
        }
        return snapWidgetHelper(snap, loadingWidget: Offstage()).center();
      },
    );
  }
  Widget buildSomethingElse(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // ...
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          // ...
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // ...
        }

        return ListView.builder(
          // ...
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String userId = document.id;
            bool isVerified = false;
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
            if (userData.containsKey('isVerified')) {
              isVerified = userData['isVerified'];
            }

            return ListTile(
              // ...
              leading: CircleAvatar(
                // ...
                child: isVerified
                    ? Icon(Icons.verified, color: Colors.blue)
                    : null,
              ),
              // ...
            );
          },
        );
      },
    );
  }
  bool isUserVerified = false;

  void checkUserVerification(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId ?? '')
          .update({'isVerified': true});
      print('User verified successfully!');
    } catch (error) {
      print('Failed to verify user: $error');
    }

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId ?? '')
        .get();
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('isVerified')) {
        isUserVerified = userData['isVerified'];
      }
    }
  }


  StreamBuilder<List<dynamic>> _builGroupItemWidget({required ContactModel contact}) {
    return StreamBuilder(
      stream: group(searchText: ''),
      builder: (_, snap) {
        if (snap.hasData) {
          if (snap.data!.length == 0) {
            return noDataFound();
          }
        }
        return snap.data != null
            ? ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                itemCount: snap.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  var members = snap.data![index]['memberslist'];
                  var data;
                  members.map((e) {
                    if (e.contains(getStringAsync(userId)) && contact.groupRefUrl == snap.data![index]['id']) {
                      data = snap.data![index];
                    }
                  }).toList();
                  return data != null
                      ? InkWell(
                          onTap: () {
                            setValue(CURRENT_GROUP_ID, data['id']);
                            GroupChatRoom(groupChatId: data['id'], groupName: data['name'], groupData: data).launch(context);
                          },
                          onLongPress: () async {
                            setValue(CURRENT_GROUP_ID, data['id']);
                            await showInDialog(
                              context,
                              builder: (p0) {
                                return ChatOptionDialog(isGroup: true);
                              },
                              contentPadding: EdgeInsets.zero,
                              dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                            );
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                data['photourl'] == null
                                    ? noProfileImageFound(height: 50, width: 50, isGroup: true).cornerRadiusWithClipRRect(50).onTap(() {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return GroupProfileImageDailog(data: data);
                                          },
                                        );
                                      })
                                    : Hero(
                                        tag: data['photourl'],
                                        child: Image.network(
                                          data['photourl'],
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return noProfileImageFound(height: 50, width: 50, isGroup: true);
                                          },
                                        ).cornerRadiusWithClipRRect(50),
                                      ).onTap(() {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return GroupProfileImageDailog(data: data);
                                          },
                                        );
                                      }),
                                10.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data['name'].toString().capitalizeFirstLetter(),
                                          style: primaryTextStyle(size: 18),
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ).expand(),
                                        2.width,
                                      ],
                                    ),
                                    2.height,
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        LastMessageContainer(
                                          stream: groupChatMessageService.fetchLastMessageBetween(groupDocId: data['id']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ),
                        )
                      : SizedBox();
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox();
                },
              )
            : SizedBox();
      },
    );
  }
}
