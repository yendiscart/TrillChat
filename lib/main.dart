import 'package:chat/screens/TransactionScreen.dart';
import 'package:chat/screens/WalletScreen.dart';
import 'package:chat/services/DeviceService.dart';
import 'package:chat/services/PayOutService.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../models/FileModel.dart';
import '../../models/Language.dart';
import '../../screens/SplashScreen.dart';
import '../../services/AuthService.dart';
import '../../services/CallService.dart';
import '../../services/ChatMessageService.dart';
import '../../services/ChatRequestService.dart';
import '../../services/GroupChatMessageService.dart';
import '../../services/NotificationService.dart';
import '../../services/StoryService.dart';
import '../../services/UserService.dart';
import '../../store/AppSettingStore.dart';
import '../../store/AppStore.dart';
import '../../store/LoginStore.dart';
import '../../store/MessageRequestStore.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import '../../utils/AppTheme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sqflite/sqflite.dart';

//region Services Objects
UserService userService = UserService();
AuthService authService = AuthService();
DeviceService deviceService = DeviceService();
ChatMessageService chatMessageService = ChatMessageService();
CallService callService = CallService();
NotificationService notificationService = NotificationService();
StoryService storyService = StoryService();
ChatRequestService chatRequestService = ChatRequestService();
PayOutService payOutService = PayOutService();
FirebaseFirestore fireStore = FirebaseFirestore.instance;

GroupChatMessageService groupChatMessageService=GroupChatMessageService();
// late AssetsAudioPlayer assetsAudioPlayer;
//endregion
late AppLocalizations? appLocalizations;
late Language? language;
List<Language> languages = Language.getLanguages();
late List<FileModel> fileList = [];
OneSignal oneSignal = OneSignal();

//region MobX Objects
AppStore appStore = AppStore();
LoginStore loginStore = LoginStore();
AppSettingStore appSettingStore = AppSettingStore();
MessageRequestStore messageRequestStore = MessageRequestStore();
//endregion

late MessageType? messageType;

//region Default Settings
int mChatFontSize = 16;
int mAdShowCount = 0;

String mSelectedImage = appStore.isDarkMode?mSelectedImageDark:"assets/default_wallpaper.png";
String mSelectedImageDark ="assets/default_wallpaper_dark.jpg";

bool mIsEnterKey = false;
List<String?> postViewedList = [];

Database? localDbInstance;
//endregion


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  Stripe.publishableKey = "pk_test_51HMsYfGjHWuypmQRj3coo0cfBzQkmcvWvoIz8j31KyRmF5WQf2svLwwffKBQ8LzR47kF201I9dSDMWoAa4rQ5BIB00l0PyT9IY";
  Function? originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    originalOnError!(errorDetails);
  };
  await initialize();

  appSetting();

  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  appBarBackgroundColorGlobal = primaryColor;
  defaultLoaderBgColorGlobal = chatColor;
  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }

  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId(mOneSignalAppId).then((value) {
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent? event) {
      return event?.complete(event.notification);
    });

    OneSignal.shared.getDeviceState().then((value) async {
      await setValue(playerId.validate(), value!.userId.validate());
    });

    OneSignal.shared.disablePush(false);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared.requiresUserPrivacyConsent();

    OneSignal.shared.setSubscriptionObserver((changes) async {
      if (getBoolAsync(IS_LOGGED_IN)) {
        userService.updateDocument({
          'oneSignalPlayerId': changes.to.userId,
          'updatedAt': Timestamp.now(),
        }, getStringAsync(userId)).then((value) {
          log("Updated");
        }).catchError((e) {
          log(e.toString());
        });
      }
      if (!changes.to.userId.isEmptyOrNull) await setValue(playerId.validate(), changes.to.userId);
    });
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: Language.languagesLocale(),
        localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
        initialRoute: '/',
        // Define the named routes
        routes: {
          '/': (context) => SplashScreen(),
          '/wallet': (context) => WalletScreen(),
          '/transaction': (context) => TransactionScreen(),
        },
        // home: SplashScreen(),
        builder: scrollBehaviour(),
      ),
    );
  }
}
