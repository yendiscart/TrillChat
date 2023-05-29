import '../../components/ChatWidget.dart';
import '../../screens/WallpaperSelectionScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AppCommon.dart';

class WallpaperScreen extends StatefulWidget {
  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  String image = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    image = getStringAsync(SELECTED_WALLPAPER, defaultValue: "assets/default_wallpaper.png");
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("wallpaper".translate, textColor: Colors.white),
      body: body(),
    );
  }

  Widget body() {
    return Container(
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              height: context.height() * 0.55,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(image).image,
                ),
              ),
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  ChatWidget(createdAt: 20, isMe: false, message: ""),
                  ChatWidget(createdAt: 20, isMe: true, message: ""),
                ],
              ),
            ).center(),
            32.height,
            Text('change'.translate, style: primaryTextStyle(color: primaryColor)).onTap(
              () async {
                String? data = await WallpaperSelectionScreen().launch(context);
                if (data != null) {
                  image = data;
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
