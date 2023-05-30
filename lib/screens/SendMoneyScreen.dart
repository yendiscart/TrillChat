
import 'dart:developer';
import 'dart:io';

import 'package:chat/main.dart';
import 'package:chat/screens/TransferScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SendMoneyScreen extends StatefulWidget {
   const SendMoneyScreen({Key? key}) : super(key: key);
  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String scannedData = '';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          /*Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Barcode Type: ${(result!.format)}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          )*/
        ],
      ),
    );
  }
  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 500.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        controller.pauseCamera();
        _handleScannedData(result!.code);
      }
    });
  }
  Future<void> _handleScannedData(String? code) async {
    try{
      var user = await userService.getUserById(val: code);
      if (user.uid != '') {
        controller!.stopCamera();
        // Navigator.pop(context);
        // TransferScreen(toId: user.uid,).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransferScreen(userTo: user)),
        );
      }else{

        controller!.resumeCamera();
      }
    }catch(e){

      controller!.resumeCamera();
    }



  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

