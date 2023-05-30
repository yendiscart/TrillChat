import '../../main.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/SaveProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/QRScannerScreen.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Observer(
        builder: (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  SaveProfileScreen(mIsShowBack: true, mIsFromLogin: false).launch(context);
                },
                child: Row(
                  children: [
                    loginStore.mPhotoUrl.validate().isNotEmpty
                        ? Hero(
                            tag: "profile_image",
                            child: CircleAvatar(
                              radius: 32.0,
                              backgroundImage: Image.network(loginStore.mPhotoUrl.validate()).image,
                            ),
                          )
                        : Hero(
                            tag: "profile_image",
                            child: CircleAvatar(
                              radius: 32.0,
                              child: Text(
                                loginStore.mDisplayName.validate()[0],
                                style: primaryTextStyle(size: 24, color: Colors.white),
                              ),
                            ),
                          ),
                    10.width,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loginStore.mDisplayName.validate(), style: boldTextStyle(size: 18)),
                        4.height,
                        Text(
                          loginStore.mStatus.validate(),
                          style: secondaryTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ).paddingAll(16),
              ),
              IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: (){
                  QRScannerScreen().launch(context);
                },
              )
            ],
          );
        },
      ),
    );
  }
}
