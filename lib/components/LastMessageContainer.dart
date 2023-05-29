import '../../models/ChatMessageModel.dart';
import '../../utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/ChatMessageService.dart';

class LastMessageContainer extends StatelessWidget {
 final  bool isGroup;
  final stream;

  LastMessageContainer({required this.stream,this.isGroup=false});

  Widget typeWidget(ChatMessageModel message) {
    String? type = message.messageType;
    switch (type) {
      case TEXT:
        return Text("${message.isEncrypt==true?decryptedData(message.message.validate()):message.message.validate()}", maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle());
      case IMAGE:
        return Row(
          children: [Icon(Icons.photo_sharp, size: 16, color: textSecondaryColor), 4.width, Text('Image', style: secondaryTextStyle())],
        );
      case VIDEO:
        return Row(
          children: [Icon(Icons.videocam_outlined, size: 16, color: textSecondaryColor), 4.width, Text('Video', style: secondaryTextStyle())],
        );
      case AUDIO:
        return Row(
          children: [Icon(Icons.audiotrack, size: 16, color: textSecondaryColor), 4.width, Text('Audio', style: secondaryTextStyle())],
        );
      case DOC:
        return Row(
          children: [Icon(FontAwesome.file, size: 16, color: textSecondaryColor), 4.width, Text('Document', style: secondaryTextStyle())],
        );
      case LOCATION:
        return Row(
          children: [Icon(Icons.location_on, size: 16, color: textSecondaryColor), 4.width, Text('Location', style: secondaryTextStyle())],
        );
      case VOICE_NOTE:
        return Row(
          children: [Icon(Icons.mic, size: 16, color: textSecondaryColor), 4.width, Text('Voice Note', style: secondaryTextStyle())],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data!.docs;

          if (docList.isNotEmpty) {
            ChatMessageModel message = ChatMessageModel.fromJson(docList.last.data() as Map<String, dynamic>);
            String time = '';
            DateTime date = DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000);
            if (date.day == DateTime.now().day) {
              time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000));
            } else {
              time = DateFormat('dd/MM/yyy').format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000));
            }
            return Row(
              children: [
                typeWidget(message).expand(),
                Text(time, style: secondaryTextStyle(size: 12)),
              ],
            ).paddingTop(2).expand();
          }
          return Text(
            "",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          );
        }
        return Text(
          "..",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        );
      },
    );
  }
}
