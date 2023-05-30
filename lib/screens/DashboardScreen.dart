import 'dart:ui';

//import 'package:chat/screens/SettingHelpScreen.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/CallLogScreen.dart';
import '../../screens/ChatListScreen.dart';
import '../../screens/NewChatScreen.dart';
import '../../screens/PickupLayout.dart';

import '../../screens/ServicesScreen.dart';
import '../../services/localDB/LogRepository.dart';
import '../../services/localDB/SqliteMethods.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/providers/AppDataProvider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'SettingScreen.dart';
import 'StoriesScreen.dart';

bool isSearch = false;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int tabIndex = 0;


  bool autoFocus = false;
  TextEditingController searchCont = TextEditingController();

  FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _tabController = TabController(vsync: this, initialIndex: 0, length: 4);

    _tabController!.addListener(() {
      setState(() {
        isSearch = false;
        tabIndex = _tabController!.index;
      });
    });

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };

    LogRepository.init(dbName: getStringAsync(userId));

    localDbInstance = await SqliteMethods.initInstance();

    UserModel admin = await fireStore.collection(ADMIN).where("email", isEqualTo: adminEmail).get().then((value) {
      return UserModel.fromJson(value.docs.first.data());
    }).catchError((e) {
     // toast(e.toString());
    });
    appSettingStore.setReportCount(aReportCount: admin.reportUserCount!, isInitialize: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isSearch)
                    TextField(
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.white,
                      onChanged: (s) {
                        LiveStream().emit(SEARCH_KEY, s);
                      },
                      style: TextStyle(color: Colors.white,fontSize: 16),
                      controller: searchCont,
                      focusNode: searchFocus,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search_here'.translate,
                        hintStyle: TextStyle(color: Colors.white,fontSize: 16),
                      ),
                    ).expand(),
                  IconButton(
                    icon: isSearch ? Icon(Icons.close) : Icon(Icons.search),
                    onPressed: () async {
                      isSearch = !isSearch;
                      searchCont.clear();
                      LiveStream().emit(SEARCH_KEY, '');
                      setState(() {});
                      log('live stream');

                      if (isSearch) {
                        300.milliseconds.delay.then(
                          (value) {
                            context.requestFocus(searchFocus);
                          },
                        );
                      }
                    },
                    color: Colors.white,
                  )
                ],
              ),
              width: isSearch ? context.width() - 86 : 50,
            ),
            PopupMenuButton(
              color: context.cardColor,
              onSelected: (dynamic value) async {
                if (tabIndex == 0) {
                  if (value == 1) {
                    NewChatScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  } else if (value == 2) {
                    SettingScreen().launch(context);
                  }
                } else if (tabIndex == 1) {
                  if (value == 1) {
                    SettingScreen().launch(context);
                  }
                } else if (tabIndex == 1) {
                  if (value == 4) {
                    print("Tusahr Tab index ............"+ tabIndex.toString());
                    ServicesScreen().launch(context);
                  }
                } else {
                  if (value == 1) {
                    bool? res = await showConfirmDialog(context, "log_confirmation".translate, buttonColor: secondaryColor);
                    if (res ?? false) {
                      LogRepository.deleteAllLogs();
                      setState(() {});
                    }
                  }
                }
              },
              itemBuilder: (context) {
                if (tabIndex == 0)
                  return dashboardPopUpMenuItem;
                else if (tabIndex == 1)
                  return statusPopUpMenuItem;
                else if (tabIndex == 3)
                  return servicesPopUpMenuItem;
                else
                  return chatLogPopUpMenuItem;
              },
            )
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelStyle: boldTextStyle(size: 12),
            unselectedLabelColor: Colors.white60,
            labelColor: Colors.white,
            onTap: (index) {
              setState(() {});
              isSearch = false;
              tabIndex = index;
            },
            tabs: [
              Tab(
                child: Column(
                  children: [
                    Icon(Icons.chat),
                    Text('Chats'.toLowerCase()),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Icon(Icons.donut_large),
                    Text('status'.toLowerCase()),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Icon(Icons.call),
                    Text('calls'.toLowerCase()),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Icon(Icons.hub),
                    Text('services'.toLowerCase()),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.pink,
          title: Image.asset('assets/app_icon.png', height: 50),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ChatListScreen(),
            StoriesScreen(),
            CallLogScreen(),
            ServicesScreen(),
          ],
        ),
      ),
    );
  }
}

