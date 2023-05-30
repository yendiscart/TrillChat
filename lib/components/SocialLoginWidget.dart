import '../../components/OTPDialog.dart';
import '../../main.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? voidCallback;

  SocialLoginWidget({this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(shape: BoxShape.circle, color: appStore.isDarkMode ? Colors.white12 : Colors.grey.shade100),
          child: GoogleLogoWidget(size: 24).onTap(
            () async {
              hideKeyboard(context);

              appStore.setLoading(true);
              // ignore: unnecessary_null_comparison
              if (getStringAsync(playerId).isEmpty || getStringAsync(playerId) == null) {
                await OneSignal.shared.getDeviceState().then((value) async {
                  setValue(playerId, value!.userId.validate());
                  await authService.signInWithGoogle().then((user) {
                    voidCallback?.call();
                  }).catchError((e) {
                    toast(e.toString());
                  });
                });
              } else {
                await authService.signInWithGoogle().then((user) {
                  voidCallback?.call();
                }).catchError((e) {
                  toast(e.toString());
                });
              }

              appStore.setLoading(false);
            },
          ),
        ).paddingRight(16),
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: appStore.isDarkMode ? Colors.white12 : Colors.grey.shade100),
          child: IconButton(
            icon: Icon(Feather.phone, color: appStore.isDarkMode ? white : black, size: 26),
            onPressed: () async {
              hideKeyboard(context);

              appStore.setLoading(true);
              await showInDialog(
                context,
                dialogAnimation: DialogAnimation.SCALE,
                builder: (p0) {
                  return OTPDialog();
                },
              );

              appStore.setLoading(false);
              // voidCallback?.call();
            },
          ),
        ),
        if (isIOS)
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: appStore.isDarkMode ? Colors.white12 : Colors.grey.shade100),
            child: IconButton(
              icon: Icon(AntDesign.apple1, color: appStore.isDarkMode ? white : black, size: 26),
              onPressed: () async {
                hideKeyboard(context);
                appStore.setLoading(true);

                await authService.appleLogIn().then((value) {
                  voidCallback?.call();
                }).catchError((e) {
                  toast(e.toString());
                });
                appStore.setLoading(false);
              },
            ),
          ).paddingLeft(16),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
