import 'dart:io';

import '../../main.dart';
import '../../screens/DashboardScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class SaveProfileScreen extends StatefulWidget {
  bool? mIsShowBack = true;
  bool? mIsFromLogin = false;

  SaveProfileScreen({this.mIsShowBack, this.mIsFromLogin});

  @override
  SaveProfileScreenState createState() => SaveProfileScreenState();
}

class SaveProfileScreenState extends State<SaveProfileScreen> {
  var formKey = GlobalKey<FormState>();
  var cropKey = GlobalKey<CropState>();

  PickedFile? image;
  File? cropImage;

  TextEditingController nameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController mobileNumberCont = TextEditingController();
  TextEditingController statusCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    appStore.setLoading(true);
    print(getBoolAsync(isEmailLogin));
    await userService.getUser(email: getStringAsync(userEmail)).then((value) {
      nameCont.text = value.name!;
      emailCont.text = value.email!;
      mobileNumberCont.text = value.phoneNumber!;
      statusCont.text = value.userStatus!;
      loginStore.setDisplayName(aDisplayName: value.name);
      loginStore.setStatus(aStatus: value.userStatus);
      loginStore.setPhotoUrl(aPhotoUrl: value.photoUrl.validate());
    }).catchError((error) {
      toast(error.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  void validate() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      appStore.isLoading = true;

      formKey.currentState!.save();
      Map<String, dynamic> data = {
        'name': nameCont.text.trim(),
        'updatedAt': Timestamp.now(),
        'phoneNumber': mobileNumberCont.text.trim(),
        "userStatus": statusCont.text.trim(),
        'caseSearch': setSearchParam(nameCont.text.trim()),
      };

      userService.updateUserInfo(data, getStringAsync(userId), profileImage: image != null ? File(image!.path) : null).then((value) {
        toast('profile_updated'.translate);

        loginStore.setDisplayName(aDisplayName: nameCont.text.trim());
        loginStore.setMobileNumber(aMobileNumber: mobileNumberCont.text.trim());
        loginStore.setStatus(aStatus: statusCont.text.trim().validate());
        if (widget.mIsFromLogin!) {
          setValue(userMobileNumber, mobileNumberCont.text.trim());
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          finish(context);
        }
      }).catchError((e) {
        log(e.toString());
        toast(e.toString());
      }).whenComplete(() {
        appStore.isLoading = false;
      });
    }
  }

  Future getImage() async {
    if (getBoolAsync(isEmailLogin)) {
      image = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 100);
      setState(() {});
    }
  }

  Widget profileImage() {
    if (image != null) {
      return Image.file(File(image!.path), height: 180, width: 180, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(80);
    } else {
      if (loginStore.mPhotoUrl.isEmptyOrNull) {
        return Image.asset('assets/user.jpg', height: 180, width: 180, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(100);
      } else {
        return cachedImage(loginStore.mPhotoUrl.validate(), height: 180, width: 180, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(80);
      }
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
    return Scaffold(
      appBar: appBarWidget('save_profile'.translate, textColor: Colors.white, showBack: widget.mIsShowBack!),
      body: Stack(
        children: [
          Stack(
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: boxDecorationWithShadow(boxShape: BoxShape.circle),
                          child: Stack(
                            children: [
                              profileImage(),
                              getBoolAsync(isEmailLogin)
                                  ? AnimatedPositioned(
                                      bottom: 8,
                                      right: 0,
                                      duration: 2.milliseconds,
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: primaryColor),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.camera_alt, color: Colors.white),
                                          onPressed: () {
                                            getImage();
                                          },
                                        ),
                                      ),
                                    )
                                  : Offstage(),
                            ],
                          ),
                        ),
                        32.height,
                        AppTextField(
                          controller: nameCont,
                          textFieldType: TextFieldType.NAME,
                          enabled: getBoolAsync(isEmailLogin) ? true : false,
                          readOnly: getBoolAsync(isEmailLogin) ? false : true,
                          decoration: inputDecoration(context, labelText: "full_name".translate).copyWith(
                            suffixIcon: Icon(Icons.contact_mail, color: secondaryColor),
                          ),
                        ),
                        16.height,
                        AppTextField(
                          controller: emailCont,
                          textFieldType: TextFieldType.EMAIL,
                          decoration: inputDecoration(context, labelText: "email".translate).copyWith(
                            suffixIcon: Icon(Icons.email_outlined, color: secondaryColor),
                          ),
                          enabled: false,
                          readOnly: true,
                        ),
                        16.height,
                        AppTextField(
                          controller: mobileNumberCont,
                          textFieldType: TextFieldType.PHONE,
                          decoration: inputDecoration(context, labelText: "mobile_number".translate).copyWith(
                            suffixIcon: Icon(Icons.phone, color: secondaryColor),
                          ),
                        ),
                        16.height,
                        AppTextField(
                          controller: statusCont,
                          textFieldType: TextFieldType.OTHER,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 130,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: inputDecoration(context, labelText: "status".translate).copyWith(
                            suffixIcon: Icon(Icons.star_border, color: secondaryColor),
                          ),
                        ),
                        16.height,
                        AppButton(
                          width: context.width(),
                          color: context.primaryColor,
                          text: "save_profile".translate,
                          hoverColor: Colors.white,
                          onTap: () {
                            validate();
                          },
                        ),
                      ],
                    ).paddingAll(16),
                  ),
                ),
              ),
            ],
          ),
          Observer(builder: (context) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
