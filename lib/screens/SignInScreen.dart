import '../../components/ForgotPasswordDialog.dart';
import '../../components/SocialLoginWidget.dart';
import '../../main.dart';
import '../../screens/DashboardScreen.dart';
import '../../screens/SaveProfileScreen.dart';
import '../../screens/SignUpScreen.dart';
import '../../services/AuthService.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var _formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (isIOS) {
      TheAppleSignIn.onCredentialRevoked!.listen((_) {
        log("Credentials revoked");
      });
    }
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
    void loginWithEmail() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        appStore.setLoading(true);
        authService.signInWithEmailPassword(email: emailCont.text, password: passCont.text).then((value) {
          appStore.setLoading(false);
          appSetting();
          DashboardScreen().launch(context, isNewTask: true);
        }).catchError((e) {
          toast(e.toString());
        }).whenComplete(
          () {
            appStore.setLoading(false);
          },
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Positioned(
                  top: -450,
                  left: -40,
                  right: -40,
                  child: Container(
                    //height: 700,
                    //width: context.width(),
                    //decoration: BoxDecoration(shape: BoxShape.circle, color: context.primaryColor),
                  ),
                ),
                Positioned(
                  top: -440,
                  left: -40,
                  right: -40,
                  child: Container(
                    height: 700,
                    width: context.width(),
                    //decoration: BoxDecoration(shape: BoxShape.circle, color: context.primaryColor.withOpacity(0.5)),
                  ),
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      70.height,
                      Image.asset("assets/app_icon.png", height: 150),
                      8.height,
                      Text(AppName, style: boldTextStyle(size: 18)),
                      30.height,
                      AppTextField(
                        controller: emailCont,
                        nextFocus: passFocus,
                        textFieldType: TextFieldType.EMAIL,
                        decoration: inputDecoration(context, labelText: "email".translate),
                      ),
                      16.height,
                      AppTextField(
                        controller: passCont,
                        focus: passFocus,
                        textFieldType: TextFieldType.PASSWORD,
                        decoration: inputDecoration(context, labelText: "password".translate),
                      ),
                      8.height,
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('forgot_password'.translate, style: primaryTextStyle(), textAlign: TextAlign.end).paddingSymmetric(vertical: 8, horizontal: 4).onTap(() {
                          return showInDialog(
                            context,
                            builder: (_) {
                              return ForgotPasswordScreen();
                            },
                            contentPadding: EdgeInsets.zero,
                            title: Text("you_forgot_your_password".translate, style: boldTextStyle(size: 20)),
                          );
                        }),
                      ),
                      16.height,
                      AppButton(
                        text: 'sign_in'.translate,
                        textStyle: boldTextStyle(color: CupertinoColors.white),
                        color: primaryColor,
                        width: context.width(),
                        onTap: () {
                          loginWithEmail();
                          hideKeyboard(context);
                        },
                      ),
                      16.height,
                      AppButton(
                        text: 'sign_up'.translate,
                        textStyle: boldTextStyle(color: textPrimaryColorGlobal),
                        color: context.cardColor,
                        width: context.width(),
                        onTap: () {
                          SignUpScreen(isOTP: false).launch(context);
                          hideKeyboard(context);
                        },
                      ),
                      26.height,
                      Text('or'.translate, style: secondaryTextStyle(), textAlign: TextAlign.center),
                      Text('login_with'.translate, style: boldTextStyle(), textAlign: TextAlign.center),
                      16.height,
                      SocialLoginWidget(
                        voidCallback: () {
                          appSetting();
                          if (getStringAsync(userMobileNumber).isEmpty || getStringAsync(userMobileNumber).isEmpty) {
                            SaveProfileScreen(mIsShowBack: false, mIsFromLogin: true).launch(context, isNewTask: true);
                          } else {
                            DashboardScreen().launch(context, isNewTask: true);
                          }
                        },
                      ),
                      16.height,
                    ],
                  ).paddingSymmetric(horizontal: 16,vertical: 8),
                ).center(),
              ],
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading).center()),
        ],
      ),
    );
  }
}
