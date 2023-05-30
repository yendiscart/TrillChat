import '../../../models/keys.dart';

class ChatRequestKeys {
  final String uid = commonKey.uid;
  final String userName = "userName";
  final String profilePic = "profilePic";
  final String requestStatus = "requestStatus";
  final String createdAt = "addedOn";
  final String senderId = "senderId";
  final String updatedAt = commonKey.updatedAt;
}

ChatRequestKeys chatRequestKeys = ChatRequestKeys();

enum RequestStatus { Pending, Rejected, Accepted }

extension status on RequestStatus {
  String get statusName {
    switch (this) {
      case RequestStatus.Pending:
        return 'Pending';

      case RequestStatus.Rejected:
        return 'Rejected';

      case RequestStatus.Accepted:
        return 'Accepted';
    }
  }
}