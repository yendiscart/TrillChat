
import 'package:chat/utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/UserListComponent.dart';
import '../main.dart';
import '../models/UserModel.dart';
import '../utils/Appwidgets.dart';


class TransferNewScreen extends StatefulWidget {
  const TransferNewScreen({Key? key}) : super(key: key);

  @override
  State<TransferNewScreen> createState() => _TransferNewScreenState();
}

class _TransferNewScreenState extends State<TransferNewScreen> {
  bool isSearch = false;
  bool autoFocus = false;
  TextEditingController searchCont = TextEditingController();
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "transfer".translate,
        textColor: Colors.white,
        actions: [
          AnimatedContainer(
            margin: EdgeInsets.only(left: 8),
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
                      hintText: 'Search here...',
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
              return noDataFound(text: isSearch ? "No Result" : "No Data Found").withHeight(context.height()).center();
            }
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [

                UserListComponent(snap: snap, isGroupCreate: false,isTransferCreate: true,)
              ]),
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }
}
