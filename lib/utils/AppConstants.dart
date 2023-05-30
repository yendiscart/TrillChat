import 'package:nb_utils/nb_utils.dart';

const AppName = 'TrillChat';
const chatMsgRadius = 12.0;

const agoraVideoCallId = "5ac3f023712845279f5fdb29da19a5ea";

//region Notification
const mFirebaseAppId = 'trillchat-b7794.appspot.com';
const mAppIconUrl = 'https://firebasestorage.googleapis.com/v0/b/$mFirebaseAppId/o/app_icon.png?alt=media&token=738b073d-c575-4a79-a257-de052dadd2e3';

const mOneSignalAppId = '41d6c212-2b88-4245-bfe5-3fcccce3a635';
const mOneSignalRestKey = 'OWEwMTY1ODYtZjdlYS00YWRkLWI1MTEtNGEzNzQxN2VjNjFl';
const mOneSignalChannelId = '8afdd025-3bdf-44e0-a0ad-3138eadaf22e';

//endregion

//region AppUrls
const packageName = "com.trillapp.yendis";
const termsAndConditionURL = 'https://trillapp.org/privacy-policy/';
const nyonsoWebsiteURL = 'https://nyonso.com/';
const TaxiWebsiteURL = 'https://tapgotaxi.ngaiyoo.com';
const privacyPolicy = 'https://trillapp.org/privacy-policy/';
const supportURL = 'https://trillapp.org/privacy-policy/';
const codeCanyonURL = 'https://www.paypal.com/paypalme/sidneytshiaba';
const appShareURL = '$playStoreBaseURL$packageName';
const mailto = 'support@yendiscart.com';
const OndemandservicesURL = 'https://services.nyonso.com';
const HousingURL = 'https://housing.trillapp.org';
const WebyonsoURL = 'https://web.nyonso.com';
const FreelanceURL = 'https://freelance.trillapp.org';
const MusicURL = 'https://music.nyonso.com';
const MoviesURL = 'https://movies.nyonso.com';
const JobsURL = 'https://jobs.trillapp.org';
const BookingURL = 'https://booking.trillapp.org';
const CourierURL = 'https://courier.nyonso.com';
const TicketeventsURL = 'https://events.trillapp.org';

//endregion

List<String> rtlLanguage = ['ar', 'ur'];

const EXCEPTION_NO_USER_FOUND = "EXCEPTION_NO_USER_FOUND";

const adminEmail = "admin@yendiscart.com";

//region AdMobIntegration
const mAdMobAppId = 'ca-app-pub-2345996790151740~3072234018';
const mAdMobBannerId ='ca-app-pub-2345996790151740/1269387129';
// const mAdMobBannerId = 'ca-app-pub-1399327544318575/9356287059';
const mAdMobInterstitialId = 'ca-app-pub-2345996790151740/2689090635';
// const mAdMobInterstitialId = 'ca-app-pub-1399327544318575/1286225341';
//endregion

const SEARCH_KEY = "Search";

const defaultLanguage = 'en';
const LANGUAGE = "LANGUAGE";
const SELECTED_LANGUAGE = "SELECTED_LANGUAGE";
enum MessageType { TEXT, IMAGE, VIDEO, AUDIO, STICKER,DOC,LOCATION ,VOICE_NOTE,TRANSACTION}

const TEXT = "TEXT";
const IMAGE = "IMAGE";
const VIDEO = "VIDEO";
const AUDIO = "AUDIO";
const DOC = "DOC";
const STICKER = "STICKER";
const LOCATION = "LOCATION";
const VOICE_NOTE="VOICE_NOTE";
const TRANSACTION="TRANSACTION";

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      case MessageType.LOCATION:
        return 'LOCATION';
      case MessageType.DOC:
        return 'DOC';
      case MessageType.STICKER:
        return 'STICKER';
      case MessageType.VOICE_NOTE:
        return 'VOICE_NOTE';
        case MessageType.TRANSACTION:
        return 'TRANSACTION';
      default:
        return null;
    }
  }
}

//FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const STORY_COLLECTION = 'story';
const CHAT_REQUEST = 'chatRequest';
const ADMIN = 'admin';
const GROUP_COLLECTION = 'groups';
const GROUP_CHATS = 'chats';
const GROUP_GROUPCHATS = 'groupChats';
const DEVICE_COLLECTION = 'device';
const TRANSACTION_COLLECTION = 'transaction';

const USER_PROFILE_IMAGE = "userProfileImage";
const CHAT_DATA_IMAGES = "chatImages";
const STORY_DATA_IMAGES = "storyImages";
const GROUP_PROFILE_IMAGE = "groupProfileImage";
const GROUP_PROFILE_IMAGES ="groupChatImages";
// Call Status For Call Logs
const CALLED_STATUS_DIALLED = "dialled";
const CALLED_STATUS_RECEIVED = "received";
const CALLED_STATUS_MISSED = "missed";

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

//Default Font Size
const FONT_SIZE_SMALL = 12;
const FONT_SIZE_MEDIUM = 16;
const FONT_SIZE_LARGE = 20;

//Pagination Setting
const PER_PAGE_CHAT_COUNT = 50;

//region SharePreference Key
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_VERIFIED = 'IS_VERIFIED';
const userId = 'userId';
const userDisplayName = 'userDisplayName';
const userEmail = 'userEmail';
const userPhotoUrl = 'userPhotoUrl';
const isEmailLogin = "isEmailLogin";
const userStatus = "userStatus";
const userMobileNumber = "userMobileNumber";
const playerId = "playerId";
const reportCount = "reportCount";
const selectedMember = "selectedMember";
//endregion

//region DefaultSettingConstant
const FONT_SIZE_INDEX = "FONT_SIZE_INDEX";
const FONT_SIZE_PREF = "FONT_SIZE_PREF";
const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";

//endregion

const TYPE_AUDIO = "audio";
const TYPE_VIDEO = "video";
const TYPE_Image = "image";
const TYPE_DOC = "doc";
const TYPE_LOCATION = "current_location";
const TYPE_VOICE_NOTE = "voice_note";
const TYPE_STICKER = "sticker";
const TYPE_TRANSACTION = "transaction";

//
const CURRENT_GROUP_ID="current_group_chat_id";

