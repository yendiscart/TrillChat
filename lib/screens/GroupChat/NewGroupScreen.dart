import '../../components/UserListComponent.dart';
import '../../main.dart';
import '../../models/ContactModel.dart';
import '../../models/UserModel.dart';
import '../../screens/GroupChat/CreateGroupScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class NewGroupScreen extends StatefulWidget {
  final AsyncSnapshot<List<UserModel>>? snap;
  final bool isAddParticipant;
  final String? groupId;
  final dynamic data;

  NewGroupScreen({this.snap, this.isAddParticipant = false, this.groupId, this.data});

  @override
  NewGroupScreenState createState() => NewGroupScreenState();
}

class NewGroupScreenState extends State<NewGroupScreen> {
  bool isSearch = false;
  bool autoFocus = false;
  TextEditingController searchCont = TextEditingController();
  String search = '';

  List<UserModel> selectedList = [];
  List<UserModel> userList = [];

  List membersList = [];
  List existingMembersList = [];
  List<UserModel> userModelList = [];
  bool isLoading = true;
  String admin = '';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getGroupDetails();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future getGroupDetails() async {
    await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).get().then((chatMap) {
      admin = chatMap['createdby'];
      membersList = chatMap['memberslist'];
      if (widget.isAddParticipant) {
        existingMembersList.addAll(membersList);
      }
      getMemberList();

      isLoading = false;
      setState(() {});
    });
  }

  getMemberList() {
    membersList.forEach((element) async {
      UserModel userm = await userService.getUserById(val: element);
      userModelList.add(userm);
      setState(() {});
    });
  }

  Future addMember() async {
    List<String> selectedNewMember = getStringListAsync(selectedMember)!;
    selectedNewMember.forEach((element) {
      membersList.add(element);
    });
    log(membersList);
    await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).update({
      "memberslist": membersList,
    }).then((value) async {
      ContactModel data = ContactModel();
      data.uid = widget.groupId;
      data.addedOn = Timestamp.now();
      data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
      data.groupRefUrl = widget.groupId;
      selectedNewMember.map((e) {
        chatMessageService.getContactsDocument(of: e, forContact: widget.groupId).set(data.toJson()).then((value) {}).catchError((e) {
          log(e);
        });
      }).toList();
      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.groupId).set(data.toJson()).then((value) {}).catchError((e) {
        log(e);
      });

      setState(() {
        isLoading = false;
      });
      finish(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        textColor: Colors.white,
        titleWidget: widget.isAddParticipant
            ? Text('lblAddparticipants'.translate, style: boldTextStyle(color: Colors.white, size: 18, letterSpacing: 0.5))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('lblCreateGroup'.translate, style: boldTextStyle(color: Colors.white, size: 18, letterSpacing: 0.5)), 4.height, Text('lblAddparticipants'.translate, style: secondaryTextStyle(color: Colors.white, letterSpacing: 0.5))],
              ),
        actions: [
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSearch)
                  TextField(
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    onChanged: (s) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white,fontSize: 16),
                    controller: searchCont,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'lblSearchHere'.translate,
                      hintStyle: TextStyle(color: Colors.white,fontSize: 16),
                    ),
                  ).expand(),
                IconButton(
                  icon: isSearch ? Icon(Icons.close) : Icon(Icons.search),
                  onPressed: () async {
                    isSearch = !isSearch;
                    searchCont.clear();
                    search = "";
                    setState(() {});
                  },
                  color: Colors.white,
                )
              ],
            ),
            width: isSearch ? context.width() - 86 : 50,
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.users(searchText: searchCont.text),
        builder: (_, snap) {
          if (snap.hasData) {
            if (snap.data!.length == 0) {
              return noDataFound().withHeight(context.height()).center();
            }
            return UserListComponent(
              snap: snap,
              isGroupCreate: true,
              isAddParticipant: widget.isAddParticipant,
              data: existingMembersList,
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
      floatingActionButton: widget.isAddParticipant
          ? FloatingActionButton(
              onPressed: () {
                appStore.isLoading = true;
                List<String> data = getStringListAsync(selectedMember)!;
                setState(() {});
                appStore.isLoading = false;

                if (data.isNotEmpty) {
                  if (widget.isAddParticipant) {
                    addMember();
                  } else {
                    CreateGroupScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 300.milliseconds);
                  }
                } else {
                  toast('lblPleaseSelectMembers'.translate);
                }
              },
              child: Icon(Icons.check, color: Colors.white),
              backgroundColor: primaryColor)
          : FloatingActionButton(
              onPressed: () {
                appStore.isLoading = true;
                List<String> data = getStringListAsync(selectedMember)!;
                print("length"+data.length.toString());
                appStore.isLoading = false;
                if (data.isNotEmpty) {
                  if (widget.isAddParticipant) {
                    //
                  } else {
                    CreateGroupScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 300.milliseconds);
                  }
                } else {
                  toast('lblPleaseSelectMembers'.translate);
                }
                setState(() {});

              },
              child: Icon(Icons.arrow_forward_outlined, color: Colors.white),
              backgroundColor: primaryColor),
    );
  }
}
