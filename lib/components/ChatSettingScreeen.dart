import '../../components/AppLanguageDialog.dart';
import '../../components/FontSelectionDialog.dart';
import '../../components/ThemeSelectionDialog.dart';
import '../../main.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/WallpaperScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ChatSettingScreen extends StatefulWidget {
  @override
  _ChatSettingScreenState createState() => _ChatSettingScreenState();
}

class _ChatSettingScreenState extends State<ChatSettingScreen> {
  bool _isEnterKey = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _isEnterKey = getBoolAsync(IS_ENTER_KEY);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return PickupLayout(
      child: Scaffold(
        appBar: appBarWidget('chats'.translate, textColor: Colors.white),
        body: ListView(
          shrinkWrap: true,
          children: [
            SettingItemWidget(
              title: 'display'.translate,
            ),
            SettingItemWidget(
              leading: Icon(Icons.wb_sunny, color: textSecondaryColor),
              title: 'theme'.translate,
              subTitle: getThemeModeString(getIntAsync(THEME_MODE_INDEX)),
              onTap: () async {
                await showInDialog(
                  context,
                  builder: (_) {
                    return ThemeSelectionDialog();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text("select_theme".translate,
                      style: boldTextStyle(size: 20)),
                );
                setState(() {});
              },
            ),
            SettingItemWidget(
              leading: Icon(Icons.wallpaper, color: textSecondaryColor),
              title: 'wallpaper'.translate,
              onTap: () {
                WallpaperScreen().launch(context);
              },
            ),
            Divider(thickness: 1, height: 0),
            SettingItemWidget(
              title: 'chat_settings'.translate,
              titleTextColor: textSecondaryColor,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.only(
                  right: 16.0, left: 40.0, top: 0.0, bottom: 00.0),
              title: Text('enter_is_send'.translate, style: boldTextStyle())
                  .paddingBottom(4),
              subtitle: Text('enter_key_will_send_your_message'.translate,
                  style: secondaryTextStyle()),
              value: _isEnterKey,
              activeColor: secondaryColor,
              onChanged: (v) {
                _isEnterKey = v;
                setValue(IS_ENTER_KEY, v);
                setState(() {});
              },
            ),
            SettingItemWidget(
              padding: EdgeInsets.only(
                  right: 16.0, left: 40.0, top: 12.0, bottom: 12.0),
              title: 'font_size'.translate,
              subTitle: getFontSizeString(
                  getIntAsync(FONT_SIZE_INDEX, defaultValue: 1)),
              subTitleTextStyle: secondaryTextStyle(),
              onTap: () async {
                await showInDialog(
                  context,
                  builder: (_) {
                    return FontSelectionDialog();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text("font_size".translate,
                      style: boldTextStyle(size: 20)),
                );
                setState(() {});
              },
            ),
            Divider(thickness: 1, height: 0),
          ],
        ),
      ),
    );
  }
}
