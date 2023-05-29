import '../../components/Permissions.dart';
import '../../models/LogModel.dart';
import '../../models/UserModel.dart';
import '../../services/localDB/LogRepository.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/CallFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<LogModel>?>(
        future: LogRepository.getLogs(),
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data!.length == 0) {
              return noDataFound(text: 'lblNoLogs'.translate);
            }
            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 0, bottom: 80),
              itemCount: snap.data!.length,
              itemBuilder: (context, index) {
                LogModel data = snap.data![index];

                bool hasDialled = data.callStatus == CALLED_STATUS_DIALLED;

                return InkWell(
                  onLongPress: () async {
                    bool? res = await showConfirmDialog(context, 'log_confirmation'.translate);
                    if (res ?? false) {
                      LogRepository.deleteLogs(data.logId);
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        cachedImage(hasDialled ? data.receiverPic.validate() : data.callerPic.validate(), height: 45, width: 45, fit: BoxFit.cover).cornerRadiusWithClipRRect(25).onTap(() {}),
                        15.width,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasDialled ? data.receiverName.validate() : data.callerName.validate(), style: boldTextStyle(letterSpacing: 0.5)),
                            5.height,
                            Row(
                              children: [
                                getCallStatusIcon(data.callStatus),
                                5.width,
                                Text('${formatDateString(data.timestamp!)}', style: primaryTextStyle()),
                              ],
                            ),
                          ],
                        ).expand(),
                        data.callType.validate() == "voice"
                            ? IconButton(
                                icon: Icon(FontAwesome.phone, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  UserModel receiverData = UserModel(
                                    name: data.receiverName,
                                    photoUrl: data.receiverPic,
                                  );
                                  UserModel sender = UserModel(
                                    name: getStringAsync(userDisplayName),
                                    photoUrl: getStringAsync(userPhotoUrl),
                                    uid: getStringAsync(userId),
                                    oneSignalPlayerId: getStringAsync(playerId),
                                  );
                                  return await Permissions.cameraAndMicrophonePermissionsGranted()
                                      ? CallFunctions.dial(
                                          context: context,
                                          from: sender,
                                          to: receiverData,
                                        )
                                      : {};
                                },
                              )
                            : IconButton(
                                icon: Icon(FontAwesome.video_camera, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  UserModel receiverData = UserModel(
                                    name: data.receiverName,
                                    photoUrl: data.receiverPic,
                                  );
                                  UserModel sender = UserModel(
                                      name: getStringAsync(userDisplayName), photoUrl: getStringAsync(userPhotoUrl), uid: getStringAsync(userId), oneSignalPlayerId: getStringAsync(playerId));
                                  return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: receiverData) : {};
                                },
                              ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return 4.height;
              },
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }
}
