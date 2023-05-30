import '../../screens/AboutUsScreen.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingHelpScreen extends StatefulWidget {
  @override
  _SettingHelpScreenState createState() => _SettingHelpScreenState();
}

class _SettingHelpScreenState extends State<SettingHelpScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("help".translate, textColor: Colors.white),
      body: ListView(
        children: [
          SettingItemWidget(
            titleTextStyle: primaryTextStyle(),
            leading: Icon(Icons.info_outline,color: textSecondaryColor),
            title: 'app_info'.translate,
            onTap: () {
              AboutUsScreen().launch(context);
            },
          ),
        ],
      ),
    );
  }
}
