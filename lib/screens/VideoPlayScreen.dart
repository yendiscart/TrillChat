// import 'package:cached_video_player/cached_video_player.dart';
import '../../utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

class VideoPlayScreen extends StatefulWidget {
  static String tag = '/VideoPlayScreen';
  final String url;

  VideoPlayScreen(this.url);

  @override
  VideoPlayScreenState createState() => VideoPlayScreenState();
}

class VideoPlayScreenState extends State<VideoPlayScreen> {
  VideoPlayerController? controller;

  bool showOverLay = false;
  bool isFullScreen = false;
  bool isBuffering = true;
  int currentPosition = 0;
  int duration = 0;
  bool isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      controller = VideoPlayerController.network(widget.url);
      setState(() {});
      init();
    });
  }

  Future<void> init() async {
    controller!.addListener(() {
      if (mounted && controller!.value.isInitialized) {
        currentPosition = controller!.value.duration.inMilliseconds == 0 ? 0 : controller!.value.position.inMilliseconds;
        duration = controller!.value.duration.inMilliseconds;
      }

      isBuffering = controller!.value.isBuffering;
      if (!controller!.value.isPlaying && !controller!.value.isBuffering) {
        if (controller!.value.duration == Duration(seconds: 0) || controller!.value.position == Duration(seconds: 0)) {
          return;
        }
      }

      if (controller!.value.isInitialized && !isVideoCompleted && controller!.value.duration.inMilliseconds == currentPosition) {
        isVideoCompleted = true;
      } else {
        isVideoCompleted = false;
      }

      this.setState(() {});
    });
    controller!.setLooping(false);

    controller!.initialize().then((_) {
      controller!.play();

      setState(() {});
    });
  }

  void handlePlayPauseVideo() {
    if (isVideoCompleted) {
      isVideoCompleted = false;

      init();
      //controller.play();
    } else {
      controller!.value.isPlaying ? controller!.pause() : controller!.play();
    }

    showOverLay = !showOverLay;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller?.removeListener(() {});
    controller?.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          AspectRatio(
            aspectRatio: controller!.value.isInitialized ? controller!.value.aspectRatio : 16 / 10,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(controller!),
                GestureDetector(
                  onTap: () {
                    showOverLay = !showOverLay;

                    setState(() {});
                  },
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 50),
                  reverseDuration: Duration(milliseconds: 200),
                  child: showOverLay
                      ? Container(
                          color: Colors.black38,
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: <Widget>[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                                        color: Colors.white,
                                        onPressed: () {
                                          !isFullScreen
                                              ? SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
                                              : SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                                          isFullScreen = !isFullScreen;
                                          setState(() {});
                                        },
                                      ).visible(!isBuffering)
                                    ],
                                  ),
                                  VideoProgressIndicator(controller!, allowScrubbing: true),
                                ],
                              ),
                              IconButton(
                                icon: Icon(controller!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 56.0),
                                onPressed: () {
                                  handlePlayPauseVideo();
                                },
                              ).center(),
                            ],
                          ),
                        ).onTap(() {
                          handlePlayPauseVideo();
                        })
                      : SizedBox.shrink(),
                ),
                CircularProgressIndicator(color: primaryColor).visible(isBuffering)
              ],
            ),
          ).center(),
          SafeArea(child: BackButton().paddingOnly(top: 16, left: 16))
        ],
      ),
    );
  }
}
