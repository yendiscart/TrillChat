
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class TransferStatusDialog extends StatefulWidget {
  final Future<String> transferFuture;

  TransferStatusDialog({required this.transferFuture});

  @override
  _TransferStatusDialogState createState() => _TransferStatusDialogState();
}

class _TransferStatusDialogState extends State<TransferStatusDialog> {
  late Future<String> _transferFuture;

  @override
  void initState() {
    super.initState();
    _transferFuture = widget.transferFuture;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  color: Colors.green,
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Icon(
                      MdiIcons.transfer,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<String>(
              future: _transferFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for the transfer result
                  return Container(
                    height: 50,
                    width: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  // Show the transfer result message

                  return Container(
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${snapshot.data.toString()}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 320.0,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1BC0C5)),
          ),
        )
      ],
    );

  }
}