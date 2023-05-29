import 'dart:io';

import '../../components/ChatItemWidget.dart';
import '../../components/MultipleSelectedAttachment.dart';
import '../../models/StickerModel.dart';
import '../../models/UserModel.dart';
import '../../screens/GroupChat/GroupInfoScreen.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/ContactModel.dart';
import '../../models/FileModel.dart';
import '../../services/ChatMessageService.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../screens/PickupLayout.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../utils/VoiceNoteRecordWidget.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  final dynamic groupData;

  GroupChatRoom({required this.groupName, required this.groupChatId, this.groupData});

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController messageCont = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isFirstMsg = false;
  String? imageUrl;

  List membersList = [];
  List<UserModel> userModelList = [];

  String? currentLat;
  String? currentLong;

  bool showPlayer = false;
  String? audioPath;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
    mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: appStore.isDarkMode ? mSelectedImageDark : "assets/default_wallpaper.png");
  }

  Future getGroupDetails() async {
    await _firestore.collection('groups').doc(widget.groupChatId).get().then((chatMap) {
      membersList = chatMap['memberslist'];
      getMemberList();
      imageUrl = chatMap['photourl'];
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

  void onSendMessageToGroup() {
    //add message to group chat collection

    ChatMessageModel chatMessageModel = ChatMessageModel();
    chatMessageModel.senderId = getStringAsync(userId);
    chatMessageModel.message = encryptData(messageCont.text);
    chatMessageModel.isMessageRead = false;
    chatMessageModel.stickerPath = null;
    chatMessageModel.isEncrypt = true;
    chatMessageModel.createdAt = DateTime.now().millisecondsSinceEpoch;
    chatMessageModel.messageType = MessageType.TEXT.name;
    sendNormalGroupMessages(chatMessageModel, result: null);
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentLat = position.latitude.toString();
    currentLong = position.longitude.toString();

    sendGroupMessage(type: TYPE_LOCATION);
  }

  void sendGroupMessage({FilePickerResult? result, String? stickerPath, File? filepath, String? type}) async {
    messageCont.clear();

    ChatMessageModel chatMessageModel = ChatMessageModel();
    chatMessageModel.senderId = sender.uid;
    chatMessageModel.message = messageCont.text;
    chatMessageModel.isMessageRead = false;
    chatMessageModel.stickerPath = stickerPath;
    chatMessageModel.isEncrypt = false;
    chatMessageModel.createdAt = DateTime.now().millisecondsSinceEpoch;
    if (result != null) {
      if (type == TYPE_Image) {
        chatMessageModel.messageType = MessageType.IMAGE.name;
      } else if (type == TYPE_VIDEO) {
        chatMessageModel.messageType = MessageType.VIDEO.name;
      } else if (type == TYPE_AUDIO) {
        chatMessageModel.messageType = MessageType.AUDIO.name;
      } else if (type == TYPE_DOC) {
        chatMessageModel.messageType = MessageType.DOC.name;
      } else if (type == TYPE_VOICE_NOTE) {
        chatMessageModel.messageType = MessageType.VOICE_NOTE.name;
        log('hello');
      } else {
        chatMessageModel.messageType = MessageType.TEXT.name;
        messageCont.text = encryptData(messageCont.text);
        chatMessageModel.message = messageCont.text;
        chatMessageModel.isEncrypt = true;
      }
    } else if (stickerPath.validate().isNotEmpty) {
      chatMessageModel.messageType = MessageType.STICKER.name;
    } else {
      if (type == TYPE_LOCATION) {
        chatMessageModel.messageType = MessageType.LOCATION.name;
        chatMessageModel.currentLat = currentLat;
        chatMessageModel.currentLong = currentLong;
      } else if (type == TYPE_VOICE_NOTE) {
        chatMessageModel.messageType = MessageType.VOICE_NOTE.name;
        log(chatMessageModel.messageType);
        log(MessageType.VOICE_NOTE.name);
      } else {
        chatMessageModel.messageType = MessageType.TEXT.name;
        messageCont.text = encryptData(messageCont.text);
        chatMessageModel.message = messageCont.text;
        chatMessageModel.isEncrypt = true;
      }
    }
    log(chatMessageModel.message);

    sendNormalGroupMessages(chatMessageModel, result: result != null ? result : null, filepath: filepath);
  }

  void sendNormalGroupMessages(ChatMessageModel data, {FilePickerResult? result, File? filepath}) async {
    ContactModel contactModel = ContactModel();
    contactModel.uid = widget.groupChatId;
    contactModel.addedOn = Timestamp.now();
    contactModel.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
    contactModel.groupRefUrl = '';
    chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.groupChatId).update(<String, dynamic>{
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
    }).catchError((e) {
      log(e);
    }).then((value) {
      userModelList.forEach((element) {
        log(element.oneSignalPlayerId);

        if (element.uid != getStringAsync(userId)) {
          notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text, receiverPlayerId: element.oneSignalPlayerId).catchError((e) {
            log('error' + e);
          });
        }
      });
    });

    messageCont.clear();
    setState(() {});

    if (data.messageType == MessageType.LOCATION.name) {
      groupChatMessageService.addLatLong(data, groupId: widget.groupChatId, lat: currentLat, long: currentLong);
    }

    groupChatMessageService.addIsEncrypt(data);

    await groupChatMessageService.addMessage(data, widget.groupChatId).then((value) async {
      if (result != null || filepath != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = result != null ? File(result.files.single.path!) : filepath;
        fileList.add(fileModel);

        setState(() {});

        await groupChatMessageService
            .addMessageToDb(
                senderDoc: value,
                data: data,
                image: result != null
                    ? File(result.files.single.path!)
                    : filepath != null
                        ? filepath
                        : null,
                isRequest: false)
            .then((value) {});
      }
    }).catchError((e) {
      log("message send:$e");
    });
  }

  _showAttachmentDialog() {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
            margin: EdgeInsets.only(bottom: 78, left: 12, right: 12),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: context.scaffoldBackgroundColor,
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  iconsBackgroundWidget(context, name: 'lblGallery'.translate, iconData: MaterialCommunityIcons.image, color: Colors.purple.shade400).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, allowCompression: true);

                    if (result != null) {
                      List<File> image = [];
                      result.files.map((e) {
                        image.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      bool res = await (MultipleSelectedAttachment(attachedFiles: image, userModel: null, isImage: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_Image);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblVideo'.translate, iconData: FontAwesome.video_camera, color: Colors.pink[400]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false, allowCompression: true);
                    if (result != null) {
                      log(result);
                      List<File> videos = [];
                      result.files.map((e) {
                        log(e.path);
                        videos.add(File(e.path.validate()));
                      }).toList();
                      log(videos);
                      finish(context);
                      bool res = await (MultipleSelectedAttachment(attachedFiles: videos, userModel: null, isVideo: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_VIDEO);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblAudio'.translate, iconData: Icons.headset, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowCompression: true, allowMultiple: false);
                    if (result != null) {
                      List<File> audio = [];
                      result.files.map((e) {
                        audio.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      result.files.map((e) {
                        sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_AUDIO);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblDocument'.translate, iconData: FontAwesome.file, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx', 'doc', 'txt', 'pdf'], allowMultiple: true);
                    if (result != null) {
                      List<File> docs = [];
                      result.files.map((e) {
                        docs.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      result.files.map((e) {
                        sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_DOC);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblLocation'.translate, iconData: Icons.location_on, color: Colors.green.shade500).onTap(
                    () async {
                      showConfirmDialog(
                        context,
                        "Are you sure you want to share your current location ?",
                        onAccept: () async {
                          bool? isEnable = await setupLocation();

                          log(isEnable);

                          if (isEnable == true) {
                            getLocation();

                            finish(context);
                          } else {
                            toast('lblPleaseEnableLocation'.translate);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> handleOnTap() async {
    bool? res = await GroupInfoScreen(
      groupName: widget.groupName,
      groupId: widget.groupChatId,
      data: widget.groupData,
    ).launch(context, pageRouteAnimation: PageRouteAnimation.Scale, duration: 300.milliseconds);
    print(res!.toString());
    if (res.toString() == 'true') {
      getGroupDetails();

      setState(() {});
    }
  }

  @override
  void dispose() {
    setValue(CURRENT_GROUP_ID, '');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(context.width(), kToolbarHeight),
          child: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      finish(context);
                    },
                    icon: Icon(Icons.arrow_back, color: whiteColor)),
                4.width,
                GestureDetector(
                  onTap: (){
                    handleOnTap();
                  },
                  child: Row(
                    children: [
                      imageUrl != null
                          ? Hero(
                              tag: 'profile',
                              child: cachedImage(imageUrl, width: 35, height: 35, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                            )
                          : noProfileImageFound(height: 35, width: 35),
                      10.width,
                      Text(widget.groupName, style: TextStyle(color: whiteColor, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: context.primaryColor,
            actions: [
              IconButton(
                  onPressed: () {
                    handleOnTap();
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(mSelectedImage).image,
                  fit: BoxFit.cover,
                  colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : null,
                ),
              ),
            ),
            PaginateFirestore(
              reverse: true,
              isLive: true,
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 100),
              physics: BouncingScrollPhysics(),
              query: groupChatMessageService.chatMessagesWithPagination(currentUserId: getStringAsync(userId), groupDocId: widget.groupChatId),
              itemsPerPage: PER_PAGE_CHAT_COUNT,
              shrinkWrap: true,
              onLoaded: (page) {
                isFirstMsg = page.documentSnapshots.isEmpty;
              },
              onEmpty: SizedBox(),
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (context, snap, index) {
                ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);

                data.isMe = data.senderId == getStringAsync(userId);

                return ChatItemWidget(data: data, isGroup: true);
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: boxDecorationWithShadow(borderRadius: BorderRadius.circular(30), spreadRadius: 0, blurRadius: 0, backgroundColor: context.cardColor),
                        padding: EdgeInsets.only(left: 0, right: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(LineIcons.smiling_face_with_heart_eyes),
                              iconSize: 24.0,
                              padding: EdgeInsets.all(2),
                              color: Colors.grey,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 8,
                                        runSpacing: 16,
                                        children: StickerModel().stickerList().map((e) {
                                          return Image.asset(e.path.validate(), height: 100, width: 100, fit: BoxFit.cover).onTap(() {
                                            hideKeyboard(context);

                                            sendGroupMessage(stickerPath: e.path);

                                            finish(context);
                                          });
                                        }).toList(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            AppTextField(
                              controller: messageCont,

                              textFieldType: TextFieldType.OTHER,

                              cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,

                              // focus: messageFocus,

                              textCapitalization: TextCapitalization.sentences,

                              keyboardType: TextInputType.multiline,

                              minLines: 1,

                              maxLines: 5,

                              textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,

                              onFieldSubmitted: (p0) {
                                onSendMessageToGroup();
                              },

                              onChanged: (s) {
                                setState(() {});
                              },

                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'lblMessage'.translate,
                                hintStyle: secondaryTextStyle(size: 16),
                                contentPadding: EdgeInsets.symmetric(vertical: 18),
                              ),
                            ).expand(),
                            IconButton(
                              visualDensity: VisualDensity(horizontal: 0, vertical: 1),
                              icon: Icon(Icons.attach_file),
                              iconSize: 25.0,
                              padding: EdgeInsets.all(2),
                              color: Colors.grey,
                              onPressed: () {
                                _showAttachmentDialog();

                                hideKeyboard(context);
                              },
                            ),
                          ],
                        ),
                        width: context.width(),
                      ).expand(),
                      8.width,
                      if (messageCont.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            onSendMessageToGroup();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white, size: 22),
                              onPressed: null,
                            ),
                          ),
                        ),
                      if (messageCont.text.isEmpty) SizedBox(width: 48)
                    ],
                  ),
                  if (messageCont.text.isEmpty)
                    AudioRecorder(
                      onStop: (path) {
                        if (kDebugMode) print('Recorded file path: $path');

                        setState(() {
                          audioPath = path;
                        });

                        sendGroupMessage(result: null, filepath: File(path), type: TYPE_VOICE_NOTE);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
