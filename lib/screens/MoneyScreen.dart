
import 'package:barcode_widget/barcode_widget.dart';
import 'package:chat/screens/ReceiveMoneyScreen.dart';
import 'package:chat/screens/SendMoneyScreen.dart';
import 'package:chat/utils/AppCommon.dart';
import 'package:chat/utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/AppColors.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({Key? key}) : super(key: key);

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.pink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text('Go Back'),
      ),
      body: Container(

        padding: const EdgeInsets.all(0.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
             /* Card(
                child: Container(
                  height: MediaQuery.of(context).size.height*.20,
                  width: double.infinity,
                ),
              ),*/
              SizedBox(height: 10,),
              Container(
                color: Colors.white,
                margin: EdgeInsets.all(12.0),
                height: MediaQuery.of(context).size.height*.40,
                padding: EdgeInsets.all(8.0),
                /* decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 2),
                ),*/
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.qrCode(
                        typeNumber: 5,
                      ),
                      data: getStringAsync(userId),
                      color: primaryColor,
                    ),
                    Positioned(
                      top: 100,
                      child: Image.asset(
                        'assets/app_icon.png', // Replace with your app icon image path
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50,),
              SizedBox(
                height: MediaQuery.of(context).size.height*.80,
                child: ListView(children: [
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(MdiIcons.cashClock,size: 30,),
                          SizedBox(width: 8,),
                          Text('receive_money'.translate),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: (){
                        ReceiveMoneyScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                    ),
                  ),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(MdiIcons.cash100,size: 30,),
                          SizedBox(width: 8,),
                          Text('send_money'.translate),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: (){
                        SendMoneyScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                      },
                    ),
                  ),
                ],),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
