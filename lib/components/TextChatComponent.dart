import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/ChatMessageService.dart';

class TextChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;

  TextChatComponent({required this.data, required this.time});

  @override
  Widget build(BuildContext context) {
    print("Tushar message is text : "+decryptedData(data.message!));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: data.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(data.isEncrypt == true ? decryptedData(data.message!) : data.message,
            style: primaryTextStyle(
              size: mChatFontSize,
            ),
            maxLines: null),
        1.height,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: secondaryTextStyle(size: 10)),
            2.width,
            data.isMe!
                ? !data.isMessageRead!
                    ? Icon(Icons.done, size: 12, color: textSecondaryColor)
                    : Icon(Icons.done_all, size: 12, color: textSecondaryColor)
                : Offstage()
          ],
        ),
      ],
    ).onTap(() {
      //
    });
  }
}
