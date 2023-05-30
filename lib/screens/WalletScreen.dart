
import 'dart:convert';

import 'package:chat/models/UserModel.dart';
import 'package:chat/screens/PaymentScreen.dart';
import 'package:chat/screens/WithdrawScreen.dart';
import 'package:chat/services/UserService.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:chat/utils/TitleColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../components/FullScreenImageWidget.dart';
import '../components/TitleTextWidget.dart';
import '../main.dart';
import '../utils/AppCommon.dart';
import '../utils/AppConstants.dart';
import '../utils/Appwidgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  bool showBalance = false;
  double balanceAmount = 0.0;
  Map<String, dynamic>? paymentIntent;

  Widget buildImageIconWidget({double? height, double? width, double? roundRadius,required UserModel user}) {
    if (user.photoUrl.validate().isNotEmpty) {
      return cachedImage(user.photoUrl.validate(), radius: 20, height: 50, width: 50, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
        FullScreenImageWidget(
          photoUrl: user.photoUrl.validate(),
          isFromChat: true,
          name: user.name.validate(),
        ).launch(context);
      });
    }
    return noProfileImageFound(height: 50, width: 50).onTap(() {
      //
    });
  }

  Widget _appBar(UserModel? user) {
    return Row(
      children: <Widget>[
        GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new)
        ),
        SizedBox(width: 5.0,),
        buildImageIconWidget(height: 50,width: 50,roundRadius: 20,user:user! ),
        SizedBox(width: 15),
        TitleText(text: "Hello,",color: Colors.black,),
        Text(' ${user.name},',
            style: GoogleFonts.mulish(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: LightColor.navyBlue2)),
        Expanded(
          child: SizedBox(),
        ),
        Icon(
          MdiIcons.notificationClearAll,
          color: Theme.of(context).iconTheme.color,
        )
      ],
    );
  }



/*  Widget _icon(Icon icon, String text,Color? color) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/transfer');
          },
          child: Container(
            height: 60,
            width: 60,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: color??Color(0xfff3f3f3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: color??Color(0xfff3f3f3),
                      offset: Offset(5, 5),
                      blurRadius: 10)
                ]),
            child: icon,
          ),
        ),
        Text(text,
            style: GoogleFonts.mulish(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff76797e))),
      ],
    );
  }*/





  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      appBar: AppBar(backgroundColor: Colors.pink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
              Navigator.pop(context);
          },
        ),
        title: Text('Go Back'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<UserModel>(
          stream: userService.singleUser(getStringAsync(userId)),
          builder: (context, snap) {
            if(snap.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    showBalance
                        ? '\$${snap.data!.balance!.toStringAsFixed(2)}'
                        : '*****',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showBalance = !showBalance;
                      });
                    },
                    child: Text(
                      showBalance ? 'Hide Balance' : 'Show Balance',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Perform top-up action
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentScreen()));

                          showAmountBottomSheet(context);
                        },
                        child: Text('Top-up'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Perform withdrawal action
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PaymentScreen()));
                        },
                        child: Text('Withdraw'),
                      ),
                    ],
                  ),
                ],
              );
            }
            return snapWidgetHelper(snap);
          }
        ),
      ),
    );*/
    return Scaffold(

        body: SafeArea(
            child: SingleChildScrollView(
              child: StreamBuilder<UserModel>(
                stream: userService.singleUser(getStringAsync(userId)),
                builder: (context, snap) {
                  if(snap.hasData){
                    return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 20),
                            _appBar(snap.data!),
                            SizedBox(
                              height: 35,
                            ),

                            Container(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * .22,
                                    color: primarySecondColor,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Total Balance,',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                            showBalance
                                            ? '\$${snap.data!.balance!=null?snap.data!.balance!.toStringAsFixed(2):0.0}': '*****',
                                                  style: GoogleFonts.mulish(
                                                      textStyle: Theme.of(context).textTheme.headline4,
                                                      fontSize: 35,
                                                      fontWeight: FontWeight.w800,
                                                      color: LightColor.lightNavyBlue),
                                                ),
                                                /*Text(
                                                ' MLR',
                                                style: TextStyle(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.w500,
                                                    color: LightColor.yellow.withAlpha(200)),
                                              ),*/
                                              ],
                                            ),
                                            /* Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                'Eq:',
                                                style: GoogleFonts.mulish(
                                                    textStyle: Theme.of(context).textTheme.headline4,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: LightColor.lightNavyBlue),
                                              ),
                                              Text(
                                                ' \$10,000',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),*/
                                            SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  showBalance=!showBalance;
                                                });
                                              },
                                              child: Container(
                                                  width: 85,
                                                  padding:
                                                  EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                                      border: Border.all(color: Colors.white, width: 1)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Icon(
                                                        MdiIcons.tapeDrive,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text("Tap",
                                                          style: TextStyle(color: Colors.white)),
                                                    ],
                                                  )),
                                            )
                                          ],
                                        ),
                                        Positioned(
                                          left: -170,
                                          top: -170,
                                          child: CircleAvatar(
                                            radius: 130,
                                            backgroundColor: primarySecondColor,
                                          ),
                                        ),
                                        Positioned(
                                          left: -160,
                                          top: -190,
                                          child: CircleAvatar(
                                            radius: 130,
                                            backgroundColor: primarySecondColor,
                                          ),
                                        ),
                                        Positioned(
                                          right: -170,
                                          bottom: -170,
                                          child: CircleAvatar(
                                            radius: 130,
                                            backgroundColor: primarySecondColor,
                                          ),
                                        ),
                                        Positioned(
                                          right: -160,
                                          bottom: -190,
                                          child: CircleAvatar(
                                            radius: 130,
                                            backgroundColor: primarySecondColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TitleText(
                              text: "operations".translate,
                              color: Colors.black,
                            ),
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              crossAxisSpacing: 2,
                              childAspectRatio: 1,

                              children: [
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        showAmountBottomSheet(context);
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.15),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.blue.withOpacity(0.15),
                                                  offset: Offset(5, 5),
                                                  blurRadius: 10)
                                            ]),
                                        child: Icon(MdiIcons.transferUp,color: Colors.blue,),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text('top_up'.translate,
                                          style: GoogleFonts.mulish(
                                              textStyle: Theme.of(context).textTheme.headline4,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff76797e))),
                                    ),
                                  ],
                                ),

                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => WithdrawScreen(currentBalance: snap.data!.balance??0.0)));
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.15),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.green.withOpacity(0.15),
                                                  offset: Offset(5, 5),
                                                  blurRadius: 10)
                                            ]),
                                        child: Icon(MdiIcons.transfer,color: Colors.green,),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text('withdraw'.translate,
                                          style: GoogleFonts.mulish(
                                              textStyle: Theme.of(context).textTheme.headline4,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff76797e))),
                                    ),
                                  ],
                                ),
                                 Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/transaction');
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.15),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.red.withOpacity(0.15),
                                                  offset: Offset(5, 5),
                                                  blurRadius: 10)
                                            ]),
                                        child: Icon(MdiIcons.wallet,color: Colors.red,),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text('transaction'.translate,
                                          style: GoogleFonts.mulish(
                                              textStyle: Theme.of(context).textTheme.headline4,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff76797e))),
                                    ),
                                  ],
                                ),
                              ],

                            ),
                            SizedBox(
                              height: 40,
                            ),
                            /* TitleText(
                            text: "Transactions",
                          ),
                          _transectionList(),*/
                          ],
                        ));
                  }else{

                  }
                  return snapWidgetHelper(snap);
                }
              ),
            )));


  }

  void showAmountBottomSheet(BuildContext context) {
    String enteredAmount = ''; // Variable to store the entered amount

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    enteredAmount = value; // Update the entered amount
                  },
                  keyboardType: TextInputType.number, // Set keyboard type to number
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')), // Restrict input to numeric values with up to 2 decimal places
                  ],
                  decoration: InputDecoration(
                    hintText: 'enter_amount'.translate,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close the bottom sheet
                    if (enteredAmount != '') {
                      await makePayment(enteredAmount);
                      // Perform action with the entered amount
                      // performActionWithAmount(double.tryParse(enteredAmount));
                    }
                  },
                  child: Text('confirm'.translate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      //STEP 2: Initialize Payment Sheet

      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent![
              'client_secret'], //Gotten from payment intent
              style: ThemeMode.dark,
              merchantDisplayName: 'Ikay'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(amount);
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet(String amount) async {
    try {

      await Stripe.instance.presentPaymentSheet().then((value) {
        double parsedAmount = double.tryParse(amount)??0.0;

        UserService().updateBalance(parsedAmount, getStringAsync(userId));
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100.0,
                  ),
                  SizedBox(height: 10.0),
                  Text("Payment Successful!"),
                ],
              ),
            ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body

      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        // 'destination':'acct_1N8i6tGdrU0DCzOh',
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51HMsYfGjHWuypmQR4mhrUOjLBXr78OVrbbxxeYFrDULRDjEihxtAmu9Rnbv6ZtDtM0pwK5lF8xXu94mKFyeE6os100JwJFWGQ5',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
