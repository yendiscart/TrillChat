
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/ChatMessageModel.dart';
import '../services/ChatMessageService.dart';

class TransactionChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;
  TransactionChatComponent({required this.data, required this.time,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: data.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Icon(
                      MdiIcons.swapHorizontal,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10), // Add some spacing between the icon and the text
                  Container(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data.isEncrypt == true ? decryptedData('\$'+data.message!) : '\$'+data.message!,
                            style: primaryTextStyle(
                              size: mChatFontSize,
                              color: data.isMe.validate()?Colors.white:Colors.black
                            ),
                            maxLines: null,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${data.isMe!?'You have made a transfer':'You have get a transfer'}',
                            style: primaryTextStyle(
                              size: mChatFontSize,
                              color: data.isMe.validate()?Colors.white:Colors.black
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
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