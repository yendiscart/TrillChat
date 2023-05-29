import '../../main.dart';
import '../../screens/DashboardScreen.dart';
import '../../screens/SaveProfileScreen.dart';
import '../../screens/SignInScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() =>   init());

  }

  init() async {
    setStatusBarColor(Colors.black.withOpacity(0.3));
    await Future.delayed(Duration(seconds: 2));
    appLocalizations = AppLocalizations.of(context);

    finish(context);

    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
    }

    if (getBoolAsync(IS_LOGGED_IN)) {
      loginData();
      if (getStringAsync(userMobileNumber).isEmpty) {
        SaveProfileScreen(mIsShowBack: false, mIsFromLogin: true).launch(context, isNewTask: true);
      } else {
        DashboardScreen().launch(context, isNewTask: true);
      }
    } else {
      SignInScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Image.asset(
            "assets/app_icon.png",
            height: 250,
            width: 250,
          ).center(),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Desktop', style: secondaryTextStyle()),
                Text("web.trillapp.org", style: primaryTextStyle(size: 24, color: primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
