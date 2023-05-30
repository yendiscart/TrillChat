import 'package:chat/components/TransferStatusDialog.dart';
import 'package:chat/models/TransactionModel.dart';
import 'package:chat/screens/WalletScreen.dart';
import 'package:chat/services/PayOutService.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:chat/utils/AppConstants.dart';
import 'package:chat/utils/TitleColor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../services/AuthService.dart';
import '../utils/AppCommon.dart';

class WithdrawScreen extends StatefulWidget {
  double? currentBalance;

  WithdrawScreen({required this.currentBalance, Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  var _formKey = GlobalKey<FormState>();

  PayOutService payOutService = PayOutService();
  TextEditingController emailCont = TextEditingController();
  TextEditingController amountCont = TextEditingController();
  final Uri _url = Uri.parse('https://flutter.dev');
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
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    void confirmWithdraw() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        appStore.setLoading(true);
        if (widget.currentBalance! >=
            double.parse(amountCont.text.toString())) {
          TransactionModel trModel = TransactionModel();
          trModel.uid = getStringAsync(userId);
          trModel.amount = double.parse(amountCont.text.toString());
          trModel.email = emailCont.text;
          trModel.status = "PENDING";
          trModel.from = getStringAsync(userId);
          trModel.transactionType = "WITHDRAW";
          trModel.createAt = new Timestamp.now();
          trModel.updatedAt = new Timestamp.now();
          payOutService.confirmPayout(trModel).then((value) {
            // appStore.setLoading(false);
            // TransactionModel tm=TransactionModel.fromJson(value.get() as Map<String, dynamic>);

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
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                          child: Icon(
                            MdiIcons.check,
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
                                  'Withdraw Successful',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildDataField('Transaction ID', value.id),
                              _buildDataField(
                                  'Amount', value.amount.toString()),
                              _buildDataField('Email', value.email),
                              _buildDataField('Reason', value.reason),
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/wallet'));
                                  },
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1BC0C5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).catchError((e) {
            toast(e.toString());
          }).whenComplete(
            () {
              appStore.setLoading(false);
            },
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Balance not available!")));
          appStore.setLoading(false);
        }
      }
    }

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
              decoration: BoxDecoration(color: primaryColor),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 120),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 80,left: 20,right: 20),
                    child: Text(
                        'payout_message'.translate,
                        textAlign: TextAlign.center,
                        style: TextStyle(),),
                  ),
                  SizedBox(height: 10.0,),
                  GestureDetector(
                    onTap: (){
                      _launchUrl();
                    },
                    child: Text('Terms And Conditions apply',style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTextField(
                            controller: emailCont,
                            textFieldType: TextFieldType.EMAIL,
                            decoration: inputDecoration(context,
                                labelText: "email".translate),
                          ),
                          16.height,
                          AppTextField(
                            controller: amountCont,
                            textFieldType: TextFieldType.NUMBER,
                            decoration:
                                inputDecoration(context, labelText: "Amount"),
                          ),
                          16.height,
                          AppButton(
                            text: 'confirm'.translate,
                            textStyle:
                                boldTextStyle(color: CupertinoColors.white),
                            color: primaryColor,
                            width: context.width(),
                            onTap: () {
                              confirmWithdraw();
                              hideKeyboard(context);
                            },
                          ),
                          16.height,
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                    ).center(),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: 300,
                height: 100,
                margin: EdgeInsets.only(top: 75),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    color: LightColor.navyBlue3,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Center(
                  child: Text(
                    'PayPal',
                    style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Observer(
                builder: (_) => Loader().visible(appStore.isLoading).center()),
          ],
        ),
      ),
    );
  }
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
