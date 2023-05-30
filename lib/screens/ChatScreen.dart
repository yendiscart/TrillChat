import 'dart:io';
import '../../components/ChatItemWidget.dart';
import '../../components/ChatTopWidget.dart';
import '../../components/MultipleSelectedAttachment.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/ChatRequestModel.dart';
import '../../models/ContactModel.dart';
import '../../models/FileModel.dart';
import '../../models/StickerModel.dart';
import '../../models/UserModel.dart';
import '../../screens/PickupLayout.dart';
import '../../services/ChatMessageService.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/providers/ChatRequestProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../utils/VoiceNoteRecordWidget.dart';
import 'TransferScreen.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? receiverUser;

  ChatScreen(this.receiverUser);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatMessageService chatMessageService;
  String id = '';

  InterstitialAd? myInterstitial;

  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();

  bool isFirstMsg = false;
  bool isBlocked = false;

  String? currentLat;
  String? currentLong;

  bool showPlayer = false;
  String? audioPath;

  Future<bool>? requestData;

  @override
  void initState() {
    super.initState();
    init();

    if (mAdShowCount < 5) {
      mAdShowCount++;
    } else {
      mAdShowCount = 0;
      buildInterstitialAd();
    }
  }
  // ignore: body_might_complete_normally_nullable
  InterstitialAd? buildInterstitialAd() {
    InterstitialAd.load(
      adUnitId:mAdMobInterstitialId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdFailedToLoad: (LoadAdError error) {
        throw error.message;
      }, onAdLoaded: (InterstitialAd ad) {
        ad.show();
      }),
    );
  }

  init() async {
    WidgetsBinding.instance.addObserver(this);
    oneSignal.disablePush(true);

    id = getStringAsync(userId);

    mChatFontSize = getIntAsync(FONT_SIZE_PREF, defaultValue: 16);
    mIsEnterKey = getBoolAsync(IS_ENTER_KEY, defaultValue: false);
    mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: appStore.isDarkMode ? mSelectedImageDark : "assets/default_wallpaper.png");

    chatMessageService = ChatMessageService();
    chatMessageService.setUnReadStatusToTrue(senderId: sender.uid!, receiverId: widget.receiverUser!.uid!);
    isBlocked = await userService.isUserBlocked(widget.receiverUser!.uid!);

    requestData = chatRequestService.isRequestsUserExist(widget.receiverUser!.uid!);
    setState(() {});
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentLat = position.latitude.toString();
    currentLong = position.longitude.toString();

    sendMessage(type: TYPE_LOCATION);
    if (messageCont.text.trim().isEmpty) {
      // messageFocus.requestFocus();
      return;
    }
  }

  void sendMessage({FilePickerResult? result, String? stickerPath, File? filepath, String? type}) async {
    log(type == TYPE_VOICE_NOTE);
    print("Step2");

    if (isBlocked.validate(value: false)) {
      unblockDialog(context, receiver: widget.receiverUser!);
      return;
    }

    ChatMessageModel data = ChatMessageModel();
    data.receiverId = widget.receiverUser!.uid;
    data.senderId = sender.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.stickerPath = stickerPath;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.isEncrypt = false;
    if (result != null) {
      if (type == TYPE_Image) {
        print("Step3");

        data.messageType = MessageType.IMAGE.name;
      } else if (type == TYPE_VIDEO) {
        data.messageType = MessageType.VIDEO.name;
      } else if (type == TYPE_AUDIO) {
        data.messageType = MessageType.AUDIO.name;
      } else if (type == TYPE_DOC) {
        log(MessageType.DOC.name);
        data.messageType = MessageType.DOC.name;
      } else if (type == TYPE_VOICE_NOTE) {
        data.messageType = MessageType.VOICE_NOTE.name;
      }else if (type == TYPE_TRANSACTION) {
        data.messageType = MessageType.TRANSACTION.name;
      } else {
        data.messageType = MessageType.TEXT.name;
        data.message = encryptData(messageCont.text);
        data.isEncrypt = true;
        log(data.messageType);
        log(messageCont.text);
      }
    } else if (stickerPath.validate().isNotEmpty) {
      data.messageType = MessageType.STICKER.name;
    } else {
      if (type == TYPE_LOCATION) {
        data.messageType = MessageType.LOCATION.name;
        data.currentLat = currentLat;
        data.currentLong = currentLong;
      } else if (type == TYPE_VOICE_NOTE) {
        data.messageType = MessageType.VOICE_NOTE.name;
        log(data.messageType);
        log(MessageType.VOICE_NOTE.name);
      } else {
        data.messageType = MessageType.TEXT.name;
        data.message = encryptData(messageCont.text);
        data.isEncrypt = true;
      }
    }

    if (!widget.receiverUser!.blockedTo!.contains(userService.getUserReference(uid: getStringAsync(userId)))) {
      print("Step4");

      if (await chatRequestService.isRequestsUserExist(widget.receiverUser!.uid!)) {
        print("Step5");
        sendNormalMessages(data, result: result != null ? result : null, filepath: filepath);
      } else {
        print("Step6");
        sendChatRequest(data, result: result != null ? result : null, file: filepath);
      }

      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).update(<String, dynamic>{
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      print("Step7");
      data.isMessageRead = true;
      chatMessageService.addMessage(data).then((value) {
        messageCont.clear();
        setState(() {});
      });
    }
  }

  void sendNormalMessages(ChatMessageModel data, {FilePickerResult? result, File? filepath}) async {
    if (isFirstMsg) {
      ContactModel data = ContactModel();
      data.uid = widget.receiverUser!.uid;
      data.addedOn = Timestamp.now();
      data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;

      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).set(data.toJson()).then((value) {
        //
      }).catchError((e) {
        log(e);
      });
    }
    notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text, receiverPlayerId: widget.receiverUser!.oneSignalPlayerId).catchError(log);
    messageCont.clear();
    setState(() {});
    if (data.messageType == MessageType.LOCATION.name) {
      chatMessageService.addLatLong(data, lat: currentLat, long: currentLong);
    }

    log(data.messageType == MessageType.LOCATION.name);
    log(result);
    log(filepath);
    await chatMessageService.addMessage(data).then((value) async {
      if (result != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = File(result.files.single.path!);
        fileList.add(fileModel);

        setState(() {});

        // ignore: unnecessary_null_comparison
        await chatMessageService
            .addMessageToDb(senderDoc: value, data: data, sender: sender, user: widget.receiverUser, image: result != null ? File(result.files.single.path!) : null, isRequest: false)
            .then((value) {
          //
        });
      }
    });

    userService.fireStore
        .collection(USER_COLLECTION)
        .doc(getStringAsync(userId))
        .collection(CONTACT_COLLECTION)
        .doc(widget.receiverUser!.uid)
        .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      log(e);
    });
    userService.fireStore
        .collection(USER_COLLECTION)
        .doc(widget.receiverUser!.uid)
        .collection(CONTACT_COLLECTION)
        .doc(getStringAsync(userId))
        .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      log(e);
    });
  }

  void sendChatRequest(ChatMessageModel data, {FilePickerResult? result, File? file}) async {
    if (!widget.receiverUser!.oneSignalPlayerId.isEmptyOrNull) {
      notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text, receiverPlayerId: widget.receiverUser!.oneSignalPlayerId).catchError(log);
    }
    messageCont.clear();

    ChatRequestModel chatReq = ChatRequestModel();
    chatReq.uid = data.senderId;
    chatReq.userName = "";
    chatReq.profilePic = "";
    chatReq.requestStatus = RequestStatus.Pending.index;
    chatReq.senderIdRef = userService.ref!.doc(sender.uid);
    chatReq.createdAt = DateTime.now().millisecondsSinceEpoch;
    chatReq.updatedAt = DateTime.now().millisecondsSinceEpoch;

    if (await chatRequestService.isRequestUserExist(sender.uid!, widget.receiverUser!.uid.validate())) {
      chatMessageService.addMessage(data).then((value) async {
        if (result != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = file;
          fileList.add(fileModel);

          setState(() {});
        }
        if (file != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = file;
          fileList.add(fileModel);

          setState(() {});
        }

        await chatMessageService.addMessageToDb(senderDoc: value, data: data, sender: sender, user: widget.receiverUser, image: file, isRequest: true).then((value) {
          setState(() {});
        });
      });
    } else {
      chatRequestService.addChatWithCustomId(sender.uid!, chatReq.toJson(), widget.receiverUser!.uid.validate()).then((value) {}).catchError((e) {
        //
      });
      chatMessageService.addMessage(data).then((value) async {
        if (result != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = File(result.files.single.path!);
          fileList.add(fileModel);

          setState(() {});
        }

        await chatMessageService
            .addMessageToDb(
                senderDoc: value,
                data: data,
                sender: sender,
                user: widget.receiverUser,
                image: result != null
                    ? File(result.files.single.path!)
                    : file != null
                        ? file
                        : null,
                isRequest: true)
            .then((value) {
          audioPath = null;
        });
        userService.fireStore
            .collection(USER_COLLECTION)
            .doc(getStringAsync(userId))
            .collection(CONTACT_COLLECTION)
            .doc(widget.receiverUser!.uid)
            .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
          setState(() {});
        });
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      oneSignal.disablePush(false);
    }

    if (state == AppLifecycleState.paused) {
      oneSignal.disablePush(false);
    }
    if (state == AppLifecycleState.resumed) {
      oneSignal.disablePush(true);
    }
  }

  @override
  void dispose() async {
    // myInterstitial?.show();
    oneSignal.disablePush(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget getRequestedWidget(bool isRequested) {
    if (isRequested) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: radiusOnly(
              topLeft: defaultRadius,
              topRight: defaultRadius,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message Request', style: boldTextStyle(color: Colors.white)),
              8.height,
              Row(
                children: [
                  Expanded(child: Text('if you accept the invite, ${widget.receiverUser!.name.validate()} can message you.', style: primaryTextStyle(color: Colors.white70))),
                  /*Visibility(
                    // if visibility is true, the child
                    // widget will show otherwise hide
                    visible: widget.receiverUser!.isVerified??false,
                    child: Icon(
                      Icons.verified_rounded,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ),*/
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: "Cancel",
                    color: context.primaryColor,
                    shapeBorder: OutlineInputBorder(borderRadius: radius(), borderSide: BorderSide(color: Colors.white)),
                    onTap: () {
                      chatRequestService.removeDocument(widget.receiverUser!.uid.validate()).then((value) {
                        chatMessageService.deleteChat(senderId: getStringAsync(userId), receiverId: widget.receiverUser!.uid.validate()).then((value) {
                          finish(context);
                          finish(context);
                        }).catchError((e) {
                          log(e.toString());
                        });
                      }).catchError(
                        (e) {
                          log(e.toString());
                        },
                      );
                    },
                  ),
                  16.width,
                  AppButton(
                    text: "Accept",
                    textStyle: boldTextStyle(),
                    shapeBorder: OutlineInputBorder(borderRadius: radius(), borderSide: BorderSide(color: Colors.white)),
                    onTap: () async {
                      ContactModel data = ContactModel();
                      data.uid = widget.receiverUser!.uid;
                      data.addedOn = Timestamp.now();
                      data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;

                      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).set(data.toJson()).then((value) {
                        init();
                        toast("Invitation Accepted");
                      }).catchError((e) {
                        log(e);
                      });

                      chatRequestService.updateChatRequest(widget.receiverUser!.uid,RequestStatus.Accepted.index).then((value) => null).catchError(
                            (e) {
                              log(e.toString());
                            },
                          );
                      isRequested = false;
                      setState(() {});
                    },
                  ),
                  8.width,
                ],
              )
            ],
          ),
        ),
      );
    }
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                        if (isBlocked) {
                          unblockDialog(context, receiver: widget.receiverUser!);
                          return;
                        }

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
                                    sendMessage(stickerPath: e.path, type: TYPE_STICKER);

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
                      focus: messageFocus,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,
                      onFieldSubmitted: (p0) {
                        sendMessage();
                      },
                      onChanged: (s) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'lblMessage'.translate,
                        hintStyle: secondaryTextStyle(size: 16),
                        isDense: true,
                      ),
                    ).expand(),
                    IconButton(
                      visualDensity: VisualDensity(horizontal: 0, vertical: 1),
                      icon: Icon(Icons.attach_file),
                      iconSize: 25.0,
                      padding: EdgeInsets.all(2),
                      color: Colors.grey,
                      onPressed: () {
                        if (isBlocked.validate(value: false)) {
                          unblockDialog(context, receiver: widget.receiverUser!);
                          return;
                        }
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
                    sendMessage();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    child: Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                ),
              if (messageCont.text.isEmpty) SizedBox(width: 48)
            ],
          ),
          if (messageCont.text.isEmpty)
            AudioRecorder(
              onStop: (path) {
              //  if (kDebugMode) print('Recorded file path: $path');
                setState(() {
                  audioPath = path;
                });
                sendMessage(result: null, filepath: File(audioPath!), type: TYPE_VOICE_NOTE);
              },
            ),
        ],
      ),
    );
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
                  iconsBackgroundWidget(context, name: "Gallery", iconData: MaterialCommunityIcons.image, color: Colors.purple.shade400).onTap(() async {
                  //

                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true, allowCompression: true);

                    if (result != null) {
                      List<File> image = [];
                      result.files.map((e) {
                        image.add(File(e.path.validate()));
                      }).toList();
                      // finish(context);
                      bool res = await MultipleSelectedAttachment(attachedFiles: image, userModel: widget.receiverUser, isImage: true).launch(context);
                      if (res) {
                        finish(context);
                        print("Step1");
                        result.files.map((e) {
                          sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_Image);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "Video", iconData: FontAwesome.video_camera, color: Colors.pink[400]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true, allowCompression: true);

                    if (result != null) {
                      List<File> videos = [];
                      result.files.map((e) {
                        videos.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      bool res = await (MultipleSelectedAttachment(attachedFiles: videos, userModel: widget.receiverUser, isVideo: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_VIDEO);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "Audio", iconData: Icons.headset, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowCompression: true, allowMultiple: true);
                    if (result != null) {
                      List<File> audio = [];
                      result.files.map((e) {
                        audio.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      result.files.map((e) {
                        sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_AUDIO);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "Document", iconData: FontAwesome.file, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx', 'doc', 'txt', 'pdf'], allowMultiple: true);
                    if (result != null) {
                      List<File> docs = [];
                      result.files.map((e) {
                        docs.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      result.files.map((e) {
                        log(e);
                        sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_DOC);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "Location", iconData: Icons.location_on, color: Colors.green.shade500).onTap(
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

                  iconsBackgroundWidget(context, name: "Transfer", iconData: Icons.swap_horiz, color: Colors.cyan.shade500).onTap(
                        () async {
                      showConfirmDialog(
                        context,
                        "Are you sure you want to transfer ?",
                        onAccept: () async {
                          TransferScreen(userTo: widget.receiverUser!,).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
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

  @override
  Widget build(BuildContext context) {
    Widget buildChatRequestWidget(AsyncSnapshot<bool> snap) {
      if (snap.hasData) {
        print("Tusahr request is ........... "+snap.data!.toString());
        return getRequestedWidget(snap.data!);
      } else if (snap.hasError) {
        return getRequestedWidget(false);
      } else {
        return getRequestedWidget(false);
      }
    }

    return PickupLayout(
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: PreferredSize(preferredSize: Size(context.width(), kToolbarHeight), child: ChatAppBarWidget(receiverUser: widget.receiverUser!)),
        body: Container(
          child: FutureBuilder<bool>(
            future: requestData,
            builder: (context, snap) {
              return Stack(
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
                    padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                    physics: BouncingScrollPhysics(),
                    query: chatMessageService.chatMessagesWithPagination(currentUserId: getStringAsync(userId), receiverUserId: widget.receiverUser!.uid!),
                    itemsPerPage: PER_PAGE_CHAT_COUNT,
                    shrinkWrap: true,
                    onLoaded: (page) {
                      isFirstMsg = page.documentSnapshots.isEmpty;
                    },
                    onEmpty: SizedBox(),
                    itemBuilderType: PaginateBuilderType.listView,
                    itemBuilder: (context, snap, index) {
                      ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                      data.isMe = data.senderId == id;
                      return ChatItemWidget(data: data);
                    },
                  ).paddingBottom(snap.hasData ? (snap.data! ? 176 : 76) : 76),
                  buildChatRequestWidget(snap),
                  if (isBlocked)
                    Positioned(
                      top: 16,
                      left: 32,
                      right: 32,
                      child: Container(
                        decoration: boxDecorationDefault(color: Colors.red.shade100),
                        child: TextButton(
                          onPressed: () {
                            unblockDialog(context, receiver: widget.receiverUser!);
                          },
                          child: Text('You Blocked this contact. Tap to Unblock.', style: secondaryTextStyle(color: Colors.red)),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ).onTap(() {
          hideKeyboard(context);
        }),
      ),
    );
  }
}
