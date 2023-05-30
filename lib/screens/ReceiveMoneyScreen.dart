


import 'package:barcode_widget/barcode_widget.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/AppConstants.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  const ReceiveMoneyScreen({Key? key}) : super(key: key);

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  var id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = getStringAsync(userId);
    setState(() {});
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
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              /*Container(
                  width: 250,
                  height: 250,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Container(
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(
                        typeNumber: 5,
                      ),
                      data: id,
                      color: primaryColor,

                    )

                  )// Add your QR code widget here
              ),*/
              Container(
                width: 250,
                height: 250,
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
                      data: id,
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
              SizedBox(height: 16),
              Text(
                'Align the QR code within the frame',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

      )
    );
  }
  void buildBarcode(
      Barcode bc,
      String data, {
        String? filename,
        double? width,
        double? height,
        double? fontHeight,
      }) {
    /// Create the Barcode
    final svg = bc.toSvg(
      data,
      width: width ?? 200,
      height: height ?? 80,
      fontHeight: fontHeight,
    );

    // Save the image

  }
}
