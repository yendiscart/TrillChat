
import 'package:chat/models/TransactionModel.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:chat/utils/AppCommon.dart';
import 'package:chat/utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/TitleTextWidget.dart';
import '../main.dart';
import '../utils/TitleColor.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {


  Widget _transectionList() {
    return Column(
      children: <Widget>[
        _transection("Flight Ticket", "23 Feb 2020"),
        _transection("Electricity Bill", "25 Feb 2020"),
        _transection("Flight Ticket", "03 Mar 2020"),
      ],
    );
  }

  Widget _transection(String text, String time) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: LightColor.navyBlue1,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Icon(Icons.hd, color: Colors.white),
      ),
      contentPadding: EdgeInsets.symmetric(),
      title: TitleText(
        text: text,
        fontSize: 14,
      ),
      subtitle: Text(time),
      trailing: Container(
          height: 30,
          width: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.lightGrey,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Text('-20 MLR',
              style: GoogleFonts.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: LightColor.navyBlue2))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                  color: primaryColor
              ),
            ),
            /*Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 120),

              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25),topRight:  Radius.circular(25))
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: payOutService.fetchTransaction(userId: getStringAsync(userId)),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    // print("Tusahr transaction data : ......"+snapshot.data!.docs.toString());
                    // List<TransactionModel> transactions = snapshot.data!.docs.map((doc) => TransactionModel.fromJson(doc.data())).toList();

                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 50),
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 0),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              TransactionModel transaction = TransactionModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                              return ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: LightColor.navyBlue1,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Icon(Icons.money, color: Colors.white),
                                ),
                                contentPadding: EdgeInsets.symmetric(),
                                title: TitleText(
                                  text: transaction.id.toString(),
                                  color: LightColor.navyBlue3,
                                  fontSize: 14,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status: ${transaction.status}',
                                    ),
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(transaction.createAt!.toDate()).toString(),
                                    ),

                                  ],
                                ),
                                trailing: Container(
                                  height: 30,
                                  width: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: LightColor.lightGrey,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Text(
                                    '${transaction.amount}',
                                    style: GoogleFonts.mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: LightColor.navyBlue2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }else{
                    return Container();
                  }

                }
              ),

            ),*/
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 120),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: DefaultTabController(
                length: 3, // Replace with the actual number of tabs
                child: Column(
                  children: [
                    TabBar(
                      labelColor: LightColor.lightBlue1,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: 'pending'.translate,),
                        Tab(text: 'approve'.translate),
                        Tab(text: 'reject'.translate,),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 200, // Adjust the height based on your requirements
                      child: TabBarView(
                        children: [
                          buildListViewForTab(context,0,status: 'PENDING'),
                          buildListViewForTab(context,1,status: 'ACCEPT'),
                          buildListViewForTab(context,2,status: 'REJECT'),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Observer(builder: (_) => Loader().visible(appStore.isLoading).center()),
          ],
        ),

      ),
    );
  }
  Widget buildListViewForTab(BuildContext context, int tabIndex,{String? status}) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
          stream: payOutService.fetchTransaction(userId: getStringAsync(userId),status: status),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              // print("Tusahr transaction data : ......"+snapshot.data!.docs.toString());
              // List<TransactionModel> transactions = snapshot.data!.docs.map((doc) => TransactionModel.fromJson(doc.data())).toList();

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        TransactionModel transaction = TransactionModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Container(
                                    width: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                          ),
                                          child: Icon(
                                            MdiIcons.progressAlert,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'transaction_details'.translate,
                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              _buildDataField('Transaction ID', transaction.id),
                                              _buildDataField('Amount', transaction.amount.toString()),
                                              _buildDataField('Email', transaction.email),
                                              _buildDataField('Reason', transaction.reason),
                                              _buildDataField('Status', transaction.status),
                                              SizedBox(height: 20),
                                              transaction.status=='PENDING' && getStringAsync(userEmail)==adminEmail? Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        transaction.status="REJECT";
                                                       await payOutService.updateTransaction(transaction);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Reject",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        padding: EdgeInsets.symmetric(horizontal: 30),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async{
                                                        transaction.status="ACCEPT";
                                                        await payOutService.updateTransaction(transaction);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Accept",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        padding: EdgeInsets.symmetric(horizontal: 30),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ):SizedBox(height: 0.0,),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                              },
                            );
                          },
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: LightColor.navyBlue1,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Icon(Icons.money, color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.symmetric(),
                            title: TitleText(
                              text: transaction.id.toString(),
                              color: LightColor.navyBlue3,
                              fontSize: 14,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${transaction.status}',
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(transaction.createAt!.toDate()).toString(),
                                ),

                              ],
                            ),
                            trailing: Container(
                              height: 30,
                              width: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: LightColor.lightGrey,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                '${transaction.amount}',
                                style: GoogleFonts.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: LightColor.navyBlue2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }else{
              return Container();
            }

          }
      ),
    );
  }
  Widget _buildDataField(String label, String? value) {
    if (value != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    }else{
      return SizedBox.shrink();
    }

  }
}
