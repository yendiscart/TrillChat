
import 'package:chat/utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/FullScreenImageWidget.dart';
import '../components/Permissions.dart';
import '../components/TransferStatusDialog.dart';
import '../main.dart';
import '../models/UserModel.dart';
import '../utils/AppColors.dart';
import '../utils/AppCommon.dart';
import '../utils/Appwidgets.dart';
import '../utils/CallFunctions.dart';

class TransferScreen extends StatefulWidget {
  UserModel userTo;
   TransferScreen({required this.userTo,Key? key}) : super(key: key);


  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  var currentUser;
  var enteredAmount;
  final TextEditingController amountController = TextEditingController();
  Widget buildImageIconWidget({double? height, double? width, double? roundRadius}) {
    if (currentUser.photoUrl.isNotEmpty) {
      return cachedImage(currentUser.photoUrl, radius: 50, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
        FullScreenImageWidget(
          photoUrl: currentUser.photoUrl.validate(),
          isFromChat: true,
          name: currentUser.name.validate(),
        ).launch(context);
      });
    }
    return noProfileImageFound(height: 100, width: 100).onTap(() {
      //
    });
  }

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
        body:  StreamBuilder<UserModel>(
          stream: userService.singleUser(widget.userTo.uid),
          builder: (context, snap) {
            if (snap.hasData) {
              currentUser = snap.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    buildImageIconWidget(),
                    aboutDetail(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Set border radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Set shadow color
                        spreadRadius: 2, // Set spread radius
                        blurRadius: 5, // Set blur radius
                        offset: Offset(0, 3), // Set shadow offset
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'transfer_money'.translate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          // enteredAmount = value; // Update the entered amount
                        },
                        controller: amountController,
                        keyboardType: TextInputType.number, // Set keyboard type to number
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')), // Restrict input to numeric values with up to 2 decimal places
                        ],
                        style: TextStyle(
                          fontSize: 24, // Set text size
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter_amount'.translate,

                          border: InputBorder.none, // Remove border
                          prefixIcon: Icon(Icons.attach_money), // Add a dollar icon as prefix
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Set padding
                        ),
                        textInputAction: TextInputAction.send,
                        // Set keyboard action to "Done"
                        onEditingComplete: () {
                          // Handle "Done" button press on the keyboard
                          // You can perform any necessary actions here
                          FocusScope.of(context).unfocus();
                          var sendStatus=  userService.transferBalance(double.parse(amountController.text), getStringAsync(userId), widget.userTo.uid!);

                         /* showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Transfer Status'),
                                content: Text(sendStatus),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );*/
                          if (!widget.userTo.oneSignalPlayerId.isEmptyOrNull) {
                            notificationService.sendPushNotifications(getStringAsync(userDisplayName), 'you have get a transfer from '+getStringAsync(userDisplayName), receiverPlayerId: widget.userTo.oneSignalPlayerId).catchError(log);
                          }
                          amountController.clear();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TransferStatusDialog(transferFuture: sendStatus);
                            },
                          );

                        },
                      ),
                    ],
                  ),
                ),
                ],
                ),
              );
            }
            return snapWidgetHelper(snap);
          },
        ),
    );
  }
  Widget aboutDetail() {
    return Container(
      color: context.cardColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: context.width(),
      child: Column(
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${currentUser.name}", style: boldTextStyle(letterSpacing: 0.5)),
              SizedBox(width: 2.0,),
              Visibility(
                // if visibility is true, the child
                // widget will show otherwise hide
                visible: currentUser.isVerified??false,
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              )
            ],
          ),
          8.height,
          Text(currentUser.phoneNumber.substring(0, currentUser.phoneNumber!.length - 3) + "***", style: secondaryTextStyle()),

          8.height,
        ],
      ),
    );
  }
}
