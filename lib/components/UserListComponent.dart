import 'dart:async';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class UserListComponent extends StatefulWidget {
  final AsyncSnapshot<List<UserModel>>? snap;
  final bool isGroupCreate;
  final bool isAddParticipant;
  final List<dynamic>? data;

  UserListComponent({this.snap, this.isGroupCreate = false, this.isAddParticipant = false, this.data});

  @override
  UserListComponentState createState() => UserListComponentState();
}

class UserListComponentState extends State<UserListComponent> {
  List<UserModel> _selectedList = [];
  List<String> selected = [];
  List<dynamic> existingMembersList = [];

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.data != null) {
      existingMembersList = widget.data!;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ListView.separated(
          physics: widget.isGroupCreate ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: widget.snap!.data!.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            UserModel data = widget.snap!.data![index];
            if (data.uid == loginStore.mId) {
              return 0.height;
            }
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      data.photoUrl!.isEmpty
                          ? Hero(
                              tag: data.uid.validate(),
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(10),
                                color: primaryColor,
                                child: Text(data.name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                              ).cornerRadiusWithClipRRect(50),
                            )
                          : cachedImage(data.photoUrl.validate(), width: 50, height: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(80),
                      if (selected.contains(data.uid)) Icon(Icons.check_circle, color: Colors.green)
                    ],
                  ),
                  12.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data.name.validate().capitalizeFirstLetter()}', style: primaryTextStyle()),
                      Text('${data.userStatus.validate()}', style: secondaryTextStyle()),
                    ],
                  ).expand(),
                  userService.getPreviouslyChat(data.uid!) ? Text('already_added'.translate, style: secondaryTextStyle()) : Offstage()
                ],
              ),
            ).onTap(() {
              if (widget.isGroupCreate) {
                if (!selected.contains(data.uid.toString())) {
                  if (widget.isAddParticipant) {
                    log(existingMembersList);
                    if (existingMembersList.contains(data.uid.toString())) {
                      toast('lblAlreadyExist'.translate);
                    } else {
                      selected.add(data.uid.toString());
                      _selectedList.add(data);
                    }
                  } else {
                    selected.add(data.uid.toString());
                    _selectedList.add(data);
                  }
                } else {
                  selected.remove(data.uid.toString());
                  _selectedList.remove(data);
                }
                setState(() {});
                setValue(selectedMember, selected);
              } else {
                finish(context);
                ChatScreen(data).launch(context);
              }
            });
          },
          separatorBuilder: (BuildContext context, int index) {
            if (widget.snap!.data![index].uid == getStringAsync(userId)) {
              return 0.height;
            }
            return Divider(indent: 80, height: 0);
          },
        ).paddingTop(_selectedList.isNotEmpty ? 100 : 0),
        if (widget.isGroupCreate && selected.isNotEmpty)
          Container(
            height: 80,
            width: context.width(),
            decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(0), boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black26,
                blurRadius: 0.0,
                offset: Offset(0.0, 0.0),
              ),
            ]),
            child: HorizontalList(
              reverse: _selectedList.length > 5 ? true : false,
              itemCount: _selectedList.length,
              itemBuilder: (_, i) {
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _selectedList[i].photoUrl!.isEmpty
                        ? Container(
                            height: 50,
                            width: 50,
                            padding: EdgeInsets.all(10),
                            color: primaryColor,
                            child: Text(_selectedList[i].name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                          ).cornerRadiusWithClipRRect(50)
                        : cachedImage(_selectedList[i].photoUrl, height: 50, width: 50).cornerRadiusWithClipRRect(25),
                    Icon(Icons.cancel, size: 20, color: context.iconColor).onTap(() {
                      selected.remove(_selectedList[i].uid.toString());
                      _selectedList.remove(_selectedList[i]);
                      setValue(selectedMember, selected);
                      setState(() {});
                    })
                  ],
                ).paddingAll(6);
              },
            ),
          ),
      ],
    );
  }
}
