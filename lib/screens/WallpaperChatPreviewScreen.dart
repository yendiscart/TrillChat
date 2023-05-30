import '../../components/ChatWidget.dart';
import '../../models/WallpaperModel.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class WallpaperChatPreviewScreen extends StatefulWidget {
  final int? index;
  final List<WallpaperModel>? wallpaperList;
  final bool? mIsIndividual;

  WallpaperChatPreviewScreen({this.index, this.wallpaperList, this.mIsIndividual});

  @override
  _WallpaperChatPreviewScreenState createState() => _WallpaperChatPreviewScreenState();
}

class _WallpaperChatPreviewScreenState extends State<WallpaperChatPreviewScreen> {
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pageController = PageController(initialPage: widget.index!, keepPage: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget("preview".translate, textColor: Colors.white),
        body: PageView.builder(
          controller: pageController,
          itemCount: widget.wallpaperList!.length,
          itemBuilder: (context, index) {
            WallpaperModel data = widget.wallpaperList![index];
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(data.path!).image,
                ),
              ),
              padding: EdgeInsets.only(top: 20),
              child: Stack(
                children: [
                  Column(
                    children: [
                      ChatWidget(createdAt: 20, isMe: false, message: "swipe_left_or_right_to_preview_more_wallpapers".translate),
                      ChatWidget(createdAt: 20, isMe: true, message: "set_wallpaper_for_this_theme".translate),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        ),
                      ),
                      child: AppButton(
                        color: Colors.black54,
                        shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        text: "set_wallpaper".translate,
                        onTap: () {
                          finish(context);
                          finish(context);
                          finish(context, data.path);
                          setValue(SELECTED_WALLPAPER, data.path!);
                        },
                      ).center(),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
