import '../../components/WallpaperListComponent.dart';
import '../../models/WallpaperModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AppCommon.dart';

class WallpaperSelectionScreen extends StatefulWidget {
  final bool? mIsIndividual;

  WallpaperSelectionScreen({this.mIsIndividual});

  @override
  _WallpaperSelectionScreenState createState() => _WallpaperSelectionScreenState();
}

class _WallpaperSelectionScreenState extends State<WallpaperSelectionScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget("wallpaper".translate, textColor: Colors.white),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Container(
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                WallpaperModel().wallpaperList().length,
                (index) {
                  WallpaperModel data = WallpaperModel().wallpaperList()[index];
                  return Container(
                    decoration: boxDecorationWithShadow(
                      blurRadius: 0,
                      spreadRadius: 0,
                      border: Border.all(color: viewLineColor),
                      borderRadius: BorderRadius.circular(10),
                      decorationImage: DecorationImage(
                        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.luminosity),
                        image: Image.asset("${data.path}").image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: context.width() / 2 - 24,
                    height: 180,
                    child: Text("${data.name.validate()}", style: boldTextStyle(color: Colors.white, size: 25)).center(),
                  ).onTap(() {
                    WallpaperListComponent(
                      mIsIndividual: widget.mIsIndividual,
                      name: data.name.validate(),
                      wallpaperList: data.sublist.validate(),
                    ).launch(context);
                  });
                },
              ),
            ),
            32.height,
            SettingItemWidget(
              title: "default_wallpaper".translate,
              leading: Icon(Icons.wallpaper),
              onTap: () async {
                bool? res = await showConfirmDialog(context, "are_you_sure_you_want_to_change_to_default_wallpaper".translate, buttonColor: secondaryColor);
                if (res ?? false) {
                  setValue(SELECTED_WALLPAPER, "assets/default_wallpaper.png");
                  finish(context, 'assets/default_wallpaper.png');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
