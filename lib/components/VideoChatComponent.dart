import '../../models/ChatMessageModel.dart';
import '../../screens/VideoPlayScreen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AppCommon.dart';

class VideoChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;

  VideoChatComponent({required this.data, required this.time});

  @override
  Widget build(BuildContext context) {
    if (data.photoUrl.validate().isNotEmpty || data.photoUrl != null) {
      return Container(
        height: 250,
        width: 250,
        child: Stack(
          children: [
            videoThumbnailImage(path: data.photoUrl.validate(), height: 250, width: 250),
            Container(
              decoration: boxDecorationWithShadow(backgroundColor: Colors.black38, boxShape: BoxShape.circle, spreadRadius: 0, blurRadius: 0),
              child: IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  log(data.photoUrl);
                  VideoPlayScreen(data.photoUrl.validate()).launch(context);
                  log('stop');
                },
              ),
            ).center(),
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: primaryTextStyle(color: !data.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6), size: 10),
                  ),
                  2.width,
                  data.isMe!
                      ? !data.isMessageRead!
                          ? Icon(Icons.done, size: 12, color: Colors.white60)
                          : Icon(Icons.done_all, size: 12, color: Colors.white60)
                      : Offstage()
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return SizedBox(child: Loader(), height: 250, width: 250);
    }
  }
}
