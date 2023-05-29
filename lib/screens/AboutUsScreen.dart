import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.asset("assets/aboutUs.jpg").image,
                fit: BoxFit.cover,
              ),
            ),
            width: context.width(),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snap.data!.appName.validate(), style: boldTextStyle(size: 30, color: Colors.white)),
                      8.height,
                      Text('Version ${snap.data!.version}', style: primaryTextStyle( color: Colors.white60)),
                      20.height,
                      Image.asset('assets/app_icon.png', height: 130, width: 130, fit: BoxFit.cover),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copyright,color:  Colors.white60,size: 16),8.width,
                          Text('TrillChat', style: secondaryTextStyle(color: Colors.white60, size: 16)),
                        ],
                      ),
                    ],
                  );
                }
                return snapWidgetHelper(snap);
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                finish(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
