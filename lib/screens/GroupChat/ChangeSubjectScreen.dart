import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AppCommon.dart';

class ChangeSubjectScreen extends StatefulWidget {
  final String? groupName;
  final String? groupId;

  ChangeSubjectScreen({this.groupName, this.groupId});

  @override
  ChangeSubjectScreenState createState() => ChangeSubjectScreenState();
}

class ChangeSubjectScreenState extends State<ChangeSubjectScreen> {
  final TextEditingController groupNameCont = new TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    groupNameCont.text = widget.groupName!;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.primaryColor,
        title: Text(
          'lblEnterNewSubject'.translate,
        ),
        titleTextStyle: TextStyle(fontSize: 18, color: Colors.white),
      ),
      body: Column(
        children: [
          AppTextField(
            controller: groupNameCont,
            decoration: InputDecoration(labelStyle: secondaryTextStyle(), labelText: 'subject...'),
            textFieldType: TextFieldType.NAME,
            maxLength: 25,
          ),
        ],
      ).paddingAll(16),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          log(groupNameCont);
          if (groupNameCont.text.isNotEmpty) {
            await _firestore.collection(GROUP_COLLECTION).doc(widget.groupId).update({
              "name": groupNameCont.text,
            });
            finish(context, true);
          } else {
            toast('lblPleaseaddsubject'.translate);
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
