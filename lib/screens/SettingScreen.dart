import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../components/AppLanguageDialog.dart';
import '../../components/ChatSettingScreeen.dart';
import '../../components/UserProfileWidget.dart';
import '../../main.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/SettingHelpScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import '../../screens/AboutUsScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:chat/settings_item.dart' as s;

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}
class MyWebView extends StatefulWidget {
  final String url;

  MyWebView({required this.url});

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.pink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Go Back'),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
      ),
    );
  }
}
class _SettingScreenState extends State<SettingScreen> {
  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    myBanner = buildBannerAd()..load();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: mAdMobBannerId,
      size: AdSize.fullBanner,
      listener: BannerAdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(),
    );
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
    List<Widget> _list = [





      s.SettingItemWidget(
        leading: Icon(Icons.language, color: Colors.pink, size: 22),
        title: 'app_language'.translate,
        onTap: () {
          return showInDialog(
            context,
            builder: (_) {
              return AppLanguageDialog();
            },
            contentPadding: EdgeInsets.zero,
            title: Text("app_language".translate,
                style: boldTextStyle(size: 20)),
          );
        },
        subTitle: "${language!.name.validate()}",
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        title: 'chats'.translate,
        leading: Icon(Icons.settings, color: Colors.pink, size: 22),
        //subTitle: 'theme_wallpaper'.translate,
        subTitleTextStyle: secondaryTextStyle(),
        onTap: () {
          ChatSettingScreen().launch(context).then((value) {
            setState(() {});
          });
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        leading: Icon(Icons.privacy_tip_outlined, color: Colors.pink),
        title: 'terms_and_conditions'.translate,
        //subTitle: "Buy_and_sell".translate,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWebView(url: 'https://trillapp.org/privacy-policy/')),
          );
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        leading: Icon(Icons.mail_outline, color: Colors.green),
        title: 'contact_us'.translate,
        //subTitle: "Buy_and_sell".translate,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWebView(url: 'https://trillapp.org/contact-us/')),
          );
        },
      ),

      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        title: 'invite_a_friend'.translate,
        subTitleTextStyle: secondaryTextStyle(),
        leading: Icon(Icons.group, color: Colors.pink, size: 22),
        onTap: () {
          PackageInfo.fromPlatform().then((value) {
            Share.share(
                'Share $AppName app\n\n$playStoreBaseURL${value.packageName}');
          });
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        leading: Icon(Icons.star_rate_outlined,color: Colors.yellow, size: 22),
        title: 'rate_us'.translate,
        //subTitle: "your_review_counts".translate,
        onTap: () {
          if (isIOS) {
            appLaunchUrl(appStoreBaseURL);
          } else {
            appLaunchUrl(playStoreBaseURL + packageName);
          }
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        title: 'help'.translate,
        leading: Icon(Icons.help, color: Colors.pink, size: 22),
        //subTitle: 'contact_us_privacy_policy'.translate,
        subTitleTextStyle: secondaryTextStyle(),
        onTap: () {
          AboutUsScreen().launch(context);
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        title: 'logout'.translate,
        //subTitle: 'visit_again'.translate,
        subTitleTextStyle: secondaryTextStyle(),
        leading: Icon(Icons.logout, color: Colors.red, size: 22),
        onTap: () async {
          bool? res = await showConfirmDialog(
              context, "Are you sure you want to logout?",
              buttonColor: secondaryColor);
          if (res ?? false) {
            Map<String, dynamic> presenceStatusFalse = {
              'isPresence': false,
              'lastSeen': DateTime.now().millisecondsSinceEpoch,
              'oneSignalPlayerId': '',
            };
            userService.updateUserStatus(
                presenceStatusFalse, getStringAsync(userId));
            deviceService.removeUser(
                context: context, uid: getStringAsync(userId));
            authService.logout(context);
          }
        },
      ),
      s.SettingItemWidget(
        titleTextStyle: primaryTextStyle(),
        title: 'Delete_Account'.translate,
        subTitleTextStyle: secondaryTextStyle(),
        leading:
        Icon(MaterialIcons.delete, color: Colors.red, size: 22),
        onTap: () async {
          bool? res = await showConfirmDialog(
              context, "Are you sure you want to delete this account?",
              buttonColor: secondaryColor);
          if (res ?? false) {
            appStore.setLoading(true);
            authService
                .deleteUserPermenant(uid: getStringAsync(userId))
                .then((value) {
              deviceService.removeUser(
                  context: context, uid: getStringAsync(userId));
              authService.logout(context);
              appStore.setLoading(false);
            }).catchError((e) {
              appStore.setLoading(false);
              log(e);
            });
          }
        },
      ),
    ];

    return PickupLayout(
      child: Scaffold(
        appBar: appBarWidget("setting".translate, textColor: Colors.white),
        body: Container(
          child: Column(
            children: [
              Container(child: UserProfileWidget()),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height * 0.7,
                    // color: Color.fromARGB(185, 29, 117, 48),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.3,
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (ctx, i) {
                          return _list[i];
                        }),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Column(
                      children: [
                        //Text('from'.translate, style: secondaryTextStyle())
                            //.center(),
                        6.height,
                        //Text('TrillChat',
                                //style: boldTextStyle(
                                   // letterSpacing: 2, color: primaryColor))
                            //.center(),
                        16.height,
                        if (myBanner != null)
                          SizedBox(
                            child: AdWidget(ad: myBanner!),
                            height: AdSize.banner.height.toDouble(),
                            width: context.width(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return PickupLayout(
      child: Scaffold(
        appBar: appBarWidget("setting".translate, textColor: Colors.white),
        body: Container(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView(
                children: [
                  UserProfileWidget(),
                  Divider(height: 0),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    title: 'chats'.translate,
                    leading:
                        Icon(Icons.chat, color: textSecondaryColor, size: 22),
                    //subTitle: 'theme_wallpaper'.translate,
                    subTitleTextStyle: secondaryTextStyle(),
                    onTap: () {
                      ChatSettingScreen().launch(context).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    leading: Icon(Icons.local_taxi, color: textSecondaryColor),
                    title: 'taxi_booking'.translate,
                    //subTitle: "Taxi_booking".translate,
                    onTap: () {
                      appLaunchUrl(TaxiWebsiteURL);
                    },
                  ),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    leading:
                        Icon(Icons.shopping_bag, color: textSecondaryColor),
                    title: 'online_shopping'.translate,
                    //subTitle: "Buy_and_sell".translate,
                    onTap: () {
                      appLaunchUrl(nyonsoWebsiteURL);
                    },
                  ),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    title: 'help'.translate,
                    leading:
                        Icon(Icons.help, color: textSecondaryColor, size: 22),
                    subTitle: 'contact_us_privacy_policy'.translate,
                    subTitleTextStyle: secondaryTextStyle(),
                    onTap: () {
                      SettingHelpScreen().launch(context);
                    },
                  ),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    title: 'logout'.translate,
                    //subTitle: 'visit_again'.translate,
                    subTitleTextStyle: secondaryTextStyle(),
                    leading:
                        Icon(Icons.logout, color: textSecondaryColor, size: 22),
                    onTap: () async {
                      bool? res = await showConfirmDialog(
                          context, "Are you sure you want to logout?",
                          buttonColor: secondaryColor);
                      if (res ?? false) {
                        Map<String, dynamic> presenceStatusFalse = {
                          'isPresence': false,
                          'lastSeen': DateTime.now().millisecondsSinceEpoch,
                          'oneSignalPlayerId': '',
                        };
                        userService.updateUserStatus(
                            presenceStatusFalse, getStringAsync(userId));
                        deviceService.removeUser(
                            context: context, uid: getStringAsync(userId));
                        authService.logout(context);
                      }
                    },
                  ),
                  Divider(indent: 55),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    title: 'Delete_Account'.translate,
                    subTitleTextStyle: secondaryTextStyle(),
                    leading: Icon(MaterialIcons.delete,
                        color: textSecondaryColor, size: 22),
                    onTap: () async {
                      bool? res = await showConfirmDialog(context,
                          "Are you sure you want to delete this account?",
                          buttonColor: secondaryColor);
                      if (res ?? false) {
                        appStore.setLoading(true);
                        authService
                            .deleteUserPermenant(uid: getStringAsync(userId))
                            .then((value) {
                          deviceService.removeUser(
                              context: context, uid: getStringAsync(userId));
                          authService.logout(context);
                          appStore.setLoading(false);
                        }).catchError((e) {
                          appStore.setLoading(false);
                          log(e);
                        });
                      }
                    },
                  ),
                  SettingItemWidget(
                    titleTextStyle: primaryTextStyle(),
                    title: 'invite_a_friend'.translate,
                    subTitleTextStyle: secondaryTextStyle(),
                    leading:
                        Icon(Icons.group, color: textSecondaryColor, size: 22),
                    onTap: () {
                      PackageInfo.fromPlatform().then((value) {
                        Share.share(
                            'Share $AppName app\n\n$playStoreBaseURL${value.packageName}');
                      });
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    Text('from'.translate, style: secondaryTextStyle())
                        .center(),
                    4.height,
                    Text('TrillChat',
                            style: boldTextStyle(
                                letterSpacing: 2, color: primaryColor))
                        .center(),
                    16.height,
                    if (myBanner != null)
                      SizedBox(
                        child: AdWidget(ad: myBanner!),
                        height: AdSize.banner.height.toDouble(),
                        width: context.width(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
