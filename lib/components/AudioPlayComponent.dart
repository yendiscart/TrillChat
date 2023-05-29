import '../../models/ChatMessageModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:nb_utils/nb_utils.dart';

class AudioPlayComponent extends StatefulWidget {
  final ChatMessageModel? data;
  final String? time;

  AudioPlayComponent({this.data, this.time});

  @override
  _AudioPlayComponentState createState() => _AudioPlayComponentState();
}

class _AudioPlayComponentState extends State<AudioPlayComponent> {
  // AudioPlayer audioPlayer = AudioPlayer();
  ja.AudioPlayer _player = ja.AudioPlayer();

  Duration duration = Duration();
  Duration position = Duration();
  double minValue = 0.0;
  bool isPlaying = false;
  String? audioUrl;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    audioUrl = widget.data!.photoUrl.validate();
    await _player.setUrl(audioUrl!, preload: true).then((value) {
      // log(value);
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                decoration: boxDecorationWithShadow(
                  backgroundColor: widget.data!.messageType == AUDIO ? yellowColor : Colors.grey.shade400,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                margin: EdgeInsets.all(2),
                width: 50,
                child: Icon(widget.data!.messageType == AUDIO ? Icons.headset_outlined : Icons.mic, color: Colors.white),
              ),
              4.width,
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snap) {
                      position = snap.data ?? Duration.zero;
                      if (position > duration) {
                        _player.seek(Duration(seconds: 0.0.toInt()));
                        _player.pause().whenComplete(() => isPlaying = false);
                      }
                      return Row(
                        children: [
                          audioUrl == null
                              ? CircularProgressIndicator().withHeight(25).withWidth(25).paddingAll(2)
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: scaffoldDarkColor.withOpacity(0.5),
                                ).onTap(() async {
                                  if (isPlaying) {
                                    isPlaying = false;
                                    setState(() {});
                                    await _player.pause().catchError((e) {
                                      toast(e.toString());
                                    });
                                  } else {
                                    isPlaying = true;
                                    setState(() {});
                                    await _player.play().catchError(
                                      (e) {
                                        toast(e.toString());
                                      },
                                    );
                                  }
                                }),
                          SizedBox(
                            width: 140,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3.0,
                                thumbColor: widget.data!.messageType == AUDIO ? yellowColor : Colors.grey.shade400,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                overlayColor: Colors.purple.withAlpha(32),
                                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                              ),
                              child: Slider(
                                min: 0.0,
                                thumbColor: widget.data!.messageType == AUDIO ? yellowColor : Colors.grey.shade400,
                                activeColor: yellowColor,
                                inactiveColor: Colors.grey.shade400,
                                max: duration.inSeconds.toDouble(),
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _player.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ).expand(),
            ],
          ),
          Positioned(
            bottom: 2,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.time.validate(),
                  style: primaryTextStyle(color: textSecondaryColor, size: 10),
                ),
                2.width,
                widget.data!.isMe!
                    ? !widget.data!.isMessageRead!
                        ? Icon(Icons.done, size: 12, color: textSecondaryColor)
                        : Icon(Icons.done_all, size: 12, color: textSecondaryColor)
                    : Offstage()
              ],
            ),
          )
        ],
      ),
    );
  }
}
