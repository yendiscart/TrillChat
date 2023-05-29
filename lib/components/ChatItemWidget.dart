import '../../components/AudioPlayComponent.dart';
import '../../components/ImageChatComponent.dart';
import '../../components/StickerChatComponent.dart';
import '../../components/TextChatComponent.dart';
import '../../components/VideoChatComponent.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatItemWidget extends StatefulWidget {
  final ChatMessageModel? data;
  final bool isGroup;

  ChatItemWidget({this.data, this.isGroup = false});

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  String? images;
  UserModel userModel = UserModel();

  void initState() {
    super.initState();
    init();
  }

  init() async {
    appStore.isLoading = true;
    await userService.getUserById(val: widget.data!.senderId).then((value) {
      userModel = value;
      appStore.isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String time;
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000);
    if (date.day == DateTime.now().day) {
      time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000));
    } else {
      time = DateFormat('dd-MM-yyy hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000));
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        case IMAGE:
        case VIDEO:
        case DOC:
        case LOCATION:
        case AUDIO:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
        default:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
      }
    }

    // Future<void> openFile(String filePath) async {
    //   OpenFile.open(filePath);
    // }

    Widget chatItem(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return TextChatComponent(data: widget.data!, time: time);

        case IMAGE:
          return ImageChatComponent(data: widget.data!, time: time);

        case VOICE_NOTE:
          return AudioPlayComponent(data: widget.data, time: time);

        case VIDEO:
          return VideoChatComponent(data: widget.data!, time: time);

        case DOC:
          return GestureDetector(
            onTap: () async {
              log(widget.data!.photoUrl);
              if (!widget.data!.photoUrl.validate().isEmptyOrNull) {
                await launchUrl(Uri.parse(widget.data!.photoUrl.validate()),mode: LaunchMode.externalApplication);
              } else {
                toast('Url not found');
                //throw 'could_not_launch_url'.translate;
              }
            },
            child: SizedBox(
              width: context.width() / 2 - 48,
              height: 90,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 60,
                    width: context.width() / 3 - 16,
                    child: Icon(Ionicons.document, color: scaffoldDarkColor.withOpacity(0.5), size: 30),
                  ).paddingAll(16),
                  Icon(Icons.arrow_circle_down_outlined, color: Colors.blue).paddingAll(8),
                ],
              ),
            ),
          );

        case AUDIO:
          return AudioPlayComponent(data: widget.data, time: time);

        case LOCATION:
          return Container(
            height: 200,
            width: 250,
            child: Column(
              children: [
                Image.asset('assets/map_image.jpeg', height: 180, width: 230, fit: BoxFit.cover).cornerRadiusWithClipRRect(12),
                4.height,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: primaryTextStyle(color: Colors.blueGrey.withOpacity(0.6), size: 10),
                      ),
                      2.width,
                      widget.data!.isMe!
                          ? !widget.data!.isMessageRead!
                              ? Icon(Icons.done, size: 12, color: Colors.blueGrey.withOpacity(0.6))
                              : Icon(Icons.done_all, size: 12, color: Colors.blueGrey.withOpacity(0.6))
                          : Offstage(),
                      8.width,
                    ],
                  ),
                ),
              ],
            ).onTap(() async {
              final url = 'https://www.google.com/maps/search/?api=1&query=${widget.data!.currentLat},${widget.data!.currentLong}';
              if (!url.isEmptyOrNull) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            }),
          );

        case STICKER:
          return StickerChatComponent(data: widget.data!, time: time, padding: customPadding(messageTypes));

        default:
          return Container();
      }
    }

    return GestureDetector(
      // onLongPress: (){
      //   // if(floatingKey.currentContext==null)
      //   // floatingKey = GlobalKey(debugLabel: 'Floating');
      //  if( isFloatingOpen) {
      //    floating!.remove();
      //    // floating = createFloating();
      //    // Overlay.of(context)!.insert(floating!);
      //    // Overlay.of(context)!.activate();
      //  }
      //   // setState(() {
      //     if(isFloatingOpen) floating!.remove();
      //     else {
      //       floating = createFloating();
      //       Overlay.of(context)!.insert(floating!);
      //     }
      //     isFloatingOpen = !isFloatingOpen;
      //   // });
      // },
      onLongPress: !widget.data!.isMe!
          ? null
          : () async {
              bool? res = await showConfirmDialog(context, 'Delete Message', buttonColor: secondaryColor);
              if (res ?? false) {
                hideKeyboard(context);
                if (widget.isGroup) {
                  groupChatMessageService.deleteGrpSingleMessage(groupDocId: getStringAsync(CURRENT_GROUP_ID), messageDocId: widget.data!.id).then((value) {
                    //
                  }).catchError(
                    (e) {
                      log("Error:" + e.toString());
                    },
                  );
                } else {
                  chatMessageService.deleteSingleMessage(senderId: widget.data!.senderId, receiverId: widget.data!.receiverId!, documentId: widget.data!.id).then((value) {
                    //
                  }).catchError(
                    (e) {
                      log(e.toString());
                    },
                  );
                }
              }
            },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.data!.isMe.validate() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: widget.data!.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              margin: widget.data!.isMe.validate()
                  ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                  : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),
              padding: customPadding(widget.data!.messageType),
              decoration: widget.data!.messageType != MessageType.STICKER.name
                  ? BoxDecoration(
                      boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
                      color: widget.data!.isMe.validate()
                          ? appStore.isDarkMode
                              ? primaryColor
                              : senderMessageColor
                          : context.cardColor,
                      borderRadius: widget.data!.isMe.validate()
                          ? radiusOnly(bottomLeft: chatMsgRadius, topLeft: chatMsgRadius, bottomRight: chatMsgRadius, topRight: 0)
                          : radiusOnly(bottomLeft: chatMsgRadius, topLeft: 0, bottomRight: chatMsgRadius, topRight: chatMsgRadius),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isGroup && userModel.name != null && !widget.data!.isMe.validate()) Text(userModel.name.validate(), style: boldTextStyle(size: 12, color: primaryColor)).paddingAll(1),
                  if (widget.isGroup && userModel.name != null && !widget.data!.isMe.validate()) 8.height,
                  chatItem(widget.data!.messageType),
                ],
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 2, bottom: 2),
      ),
    );
  }
}
// if (widget.isGroup && userModel.name != null && !widget.data!.isMe.validate()) 8.height,
//   Stack(
//     children: [
//       chatItem(widget.data!.messageType),
//       FlutterFeedReaction(
//         reactions: [
//           FeedReaction(
//             name: 'Like',
//             reaction: Icon(
//               Icons.star,
//               size: 35.0,
//               color: Colors.blue,
//             ),
//           ),
//           FeedReaction(
//             name: 'Love',
//             reaction: Icon(
//               Icons.star,
//               size: 35.0,
//               color: Colors.red,
//             ),
//           ),
//           FeedReaction(
//             name: 'Care',
//             reaction: Icon(
//               Icons.star,
//               size: 35.0,
//               color: Colors.deepPurple,
//             ),
//           ),
//           FeedReaction(
//             name: 'Lol',
//             reaction: Icon(
//               Icons.star,
//               size: 35.0,
//               color: Colors.yellow,
//             ),
//           ),
//           FeedReaction(
//             name: 'Sad',
//             reaction: Icon(
//               Icons.star,
//               size: 35.0,
//               color: Colors.green,
//             ),
//           ),
//         ],
//         prefix:!widget.data!.isMe.validate()?Container(color: Colors.grey,
//           ):SizedBox(),
//         suffix:widget.data!.isMe.validate()? SizedBox():Container(color: Colors.grey,
//           width: 20,height: 20,
//         ),
//         onReactionSelected: (val) {
//           toast(val.name);
//         },
//         onPressed: () {
//           toast("Pressed");
//         },
//         dragSpace: 0.0,
//       ),
//     ],
//   ),
