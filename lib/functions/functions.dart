import 'dart:convert';

import 'dart:io';
import 'dart:math';
import 'dart:async';
import "dart:developer" as develper;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagyourtaxi_driver/pages/login/get_started.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dpo_standard/dpo.dart';
import 'package:dpo_standard/models/responses/charge_response.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/editprofile.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/history.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loadingpage.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/booking_confirmation.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/review_page.dart';
import 'package:tagyourtaxi_driver/pages/referralcode/referral_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

//languages code
dynamic phcode;
dynamic platform;
dynamic pref;
String isActive = '';
double duration = 30.0;
int? paymentrils;
var audio = 'audio/notification_sound.mp3';
bool internet = true;
//   https://dumbadpo.appnexustech.in
//base url
// String url = 'https://www.mobrilz.digital/admin/public/';
String url = 'https://admin.taxiscout24.com/';
// 'https://www.mobrilz.digital/admin/public/';

String mapkey = 'AIzaSyAkoUHR7pVN2oB0ZbRTXFICCqSzSmv3HUw';

//check internet connection

//

// dev.log("s");
_handlePaymentInitialization(BuildContext context) async {
  develper.log(url);
  final style = DPOStyle(
    appBarText: "DPO",
    buttonColor: Colors.red,
    buttonTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    appBarColor: Colors.white,

    dialogCancelTextStyle: TextStyle(
      color: Colors.brown,
      fontSize: 18,
    ),
    dialogContinueTextStyle: TextStyle(
      color: Colors.purpleAccent,
      fontSize: 18,
    ),
    mainBackgroundColor: Colors.white,
    mainTextStyle:
        TextStyle(color: Colors.indigo, fontSize: 19, letterSpacing: 2),
    dialogBackgroundColor: Colors.red,
    // appBarIcon: Icon(Icons.message, color: Colors.purple),
    buttonText: "Proceed",

    appBarTitleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
    ),
  );

  final DPO dpo = DPO(
    context: context,
    style: style,
    isTestMode: false,
    paymentUrl: paymentrils.toString(),
  );

  final ChargeResponse response = await dpo.charge();
  develper.log("chageResponse ${response.success}");
  if (response != null) {
    showLoading(response.status!, context);
    print("${response.toJson()}");
  } else {
    print("${response.toJson()}");
    //showLoading(context);
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
    });
  }
}

Future<void> showLoading(String message, context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
          width: double.infinity,
          height: 50,
          child: Text(message),
        ),
      );
    },
  );
}

_onPressed(BuildContext context) {
  _handlePaymentInitialization(context);
}

checkInternetConnection() {
  Connectivity().onConnectivityChanged.listen((connectionState) {
    if (connectionState == ConnectivityResult.none) {
      internet = false;
      valueNotifierHome.incrementNotifier();
      valueNotifierBook.incrementNotifier();
    } else {
      internet = true;
      valueNotifierHome.incrementNotifier();
      valueNotifierBook.incrementNotifier();
    }
  });
}

// void printWrapped(String text) {
//   final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
//   pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
// }

getDetailsOfDevice() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    rootBundle.loadString('assets/map_style_black.json').then((value) {
      mapStyle = value;
    });

    pref = await SharedPreferences.getInstance();
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// dynamic timerLocation;
dynamic locationAllowed;
// //get current location
// getCurrentLocation() {
//   timerLocation = Timer.periodic(const Duration(seconds: 5), (timer) async {
//     var serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (serviceEnabled == true && locationAllowed == true) {
//       var loc = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.medium);

//       currentLocation = LatLng(loc.latitude, loc.longitude);
//     } else {
//       timer.cancel();
//       timerLocation = null;
//     }
//   });
// }

bool positionStreamStarted = false;
StreamSubscription<Position>? positionStream;

LocationSettings locationSettings = (platform == TargetPlatform.android)
    ? AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      )
    : AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 50,
      );

positionStreamData() {
  positionStream =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .handleError((error) {
    positionStream = null;
    positionStream?.cancel();
  }).listen((Position? position) {
    if (position != null) {
      currentLocation = LatLng(position.latitude, position.longitude);
      develper.log("currentLOcation $currentLocation");
    } else {
      positionStream!.cancel();
    }
  });
}

//validate email already exist

validateEmail() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/user/validate-mobile'),
        body: {'email': email});

        develper.log("Validate mail ${response.statusCode} === ${response.body}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 422) {
        develper.log("Validate mail statuscode 422 ${response.statusCode} === ${response.body}");
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//language code
var choosenLanguage = '';
var languageDirection = '';

List languagesCode = [
  {'name': 'German', 'code': 'de'},
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'English (UK)', 'code': 'en-GB'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {
    'name': 'Portuguese (Portugal)',
    'code': 'pt' //pt-PT
  },
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {
    'name': 'Chinese (PRC)',
    'code': 'zh'
    //zh-CN
  },
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-TW'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

//getting country code

List countries = [];
getCountryCode() async {
  dynamic result;
  try {
    final response = await http.get(Uri.parse('${url}api/v1/countries'));

    develper.log("get country code ${response} === ${response.statusCode} == ${response.body}");

    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data'];
      phcode =
          (countries.where((element) => element['default'] == true).isNotEmpty)
              ? countries.indexWhere((element) => element['default'] == true)
              : 0;
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//login firebase

String userUid = '';
var verId = '';
int? resendTokenId;
bool phoneAuthCheck = false;
dynamic credentials;

phoneAuth(String phone) async {
  try {
    credentials = null;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
        valueNotifierHome.incrementNotifier();
        develper.log("phoneAuth ${credential.token} ${credentials}=== ${email}");
      },
      forceResendingToken: resendTokenId,
      verificationFailed: (FirebaseAuthException e) {
        develper.log("phoneAuth  ${resendTokenId}=== ${email}++++${e.email}=== ${e.phoneNumber}");
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verId = verificationId;
        resendTokenId = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get local bearer token
String lastNotification = '';
getLocalData() async {
  dynamic result;
  bearerToken.clear;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    if (pref.containsKey('lastNotification')) {
      lastNotification = pref.getString('lastNotification');
    }
    if (pref.containsKey('autoAddress')) {
      var val = pref.getString('autoAddress');
      storedAutoAddress = jsonDecode(val);
    }
    if (pref.containsKey('choosenLanguage')) {
      choosenLanguage = pref.getString('choosenLanguage');
      languageDirection = pref.getString('languageDirection');
      if (choosenLanguage.isNotEmpty) {
        if (pref.containsKey('Bearer')) {
          var tokens = pref.getString('Bearer');
          if (tokens != null) {
            bearerToken.add(BearerClass(type: 'Bearer', token: tokens));

            var responce = await getUserDetails();
            if (responce == true) {
              result = '3';
            } else if (responce == false) {
              result = '2';
            }
          } else {
            result = '2';
          }
        } else {
          result = '2';
        }
      } else {
        result = '1';
      }
    } else {
      result = '1';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//register user

List<BearerClass> bearerToken = <BearerClass> [];

registerUser({
  File? image,
  String? name,
  String? email,
  String? password,
  String? confPassword,
  String? phNumber,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    // var token = await FirebaseMessaging.instance.getToken();
    // var fcm = token.toString();
    final response =
        http.MultipartRequest('POST', Uri.parse('${url}api/v1/user/register'));
    response.headers.addAll({'Content-Type': 'application/json'});
    if (image != null) {
      response.files.add(
        await http.MultipartFile.fromPath('profile_picture', image.path),
      );
    }
    response.fields.addAll({
      "name": name ?? "",
      "mobile": phNumber ?? "",
      "email": email ?? "",
      "password": password ?? "",
      "password_confirmation": confPassword ?? "",
      // "device_token": fcm,
      "country": countries[phcode]['dial_code'],
      "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
      'lang': choosenLanguage,
    });

    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (respon.statusCode == 200) {
      print("response${response.fields}");
      var jsonVal = jsonDecode(respon.body);
       SnackBar(content: Text("Successfully Register"),);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      await getUserDetails();

      result = 'true';
    } else if (respon.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

emailVerify({
  String? email,
  String? otp,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    // var token = await FirebaseMessaging.instance.getToken();
    // var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/validate-email-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "otp":otp,
          // "device_token": fcm,
        }));
        develper.log("Email verify ${response.statusCode}===${response.body}");
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

resendOtpRegister({
  String? email,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/send-mail-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "device_token": fcm,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
loginemailVerify({
  String? email,
  String? otp,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/user/login/validate-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "otp":otp,
        }));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

resendOtpLogin({
  String? email,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/send-mail-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "device_token": fcm,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
paymentgetways(
    String tolleprice,
    String firstname,
    String lastname,
    String adrress,
    String city,
    String phonenumber,
    String emails,
    BuildContext context) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('https://dumbadpo.appnexustech.in/api/v1/dpo_payment'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "paymentAmount": tolleprice,
          "paymentCurrency": 'TZS',
          "customerFirstName": firstname,
          "customerLastName": lastname,
          "customerAddress": adrress,
          "customerCity": city,
          'customerPhone': phonenumber,
          'customerEmail': emails,
          'companyRef': '34TESTREFF'
          //  "refferal_code": referralCode
        }));
        develper.log("paymentGateway ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      String jsonResponse = response.body;

      Map<String, dynamic> responseMap = json.decode(jsonResponse);
       develper.log("paymentGateway ${responseMap}===${response.statusCode}");
      if (responseMap['success'] == true) {
        paymentrils = responseMap['payment_url'];
        print('Payment URL: $paymentrils');
        _onPressed(context);
      }
    } else {
      debugPrint(response.body);
      result = 'false';
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
// paymentgetways() async {
//   bearerToken.clear();
//   dynamic result;
//   try {
//     var token = await FirebaseMessaging.instance.getToken();
//     var fcm = token.toString();
//     print('toke:::::::::::${fcm}');
//     final response =
//         http.MultipartRequest('POST', Uri.parse('https://dumbadpo.appnexustech.in/api/v1/payment/stripe/dpo_payment'));
//     response.headers.addAll({'Content-Type': 'application/json', 'Authorization': 'Bearer ${bearerToken[0].token}',});

//        response.fields.addAll({
//       "paymentAmount": '500',
//       "paymentCurrency": 'TZS',
//       "customerFirstName": 'ewded',
//       "customerLastName": 'dewdew',
//       "customerAddress": 'dewdwed',
//       "customerCity": 'dcwc',
//       'customerPhone': 'ddwewdc',
//       'customerEmail':'dcdcdc',
//       'companyRef':'34TESTREFF'
//     });

//     var request = await response.send();
//     var respon = await http.Response.fromStream(request);

//     if (respon.statusCode == 200) {
//       var jsonVal = jsonDecode(respon.body);

//       // bearerToken.add(BearerClass(
//       //     type: jsonVal['token_type'].toString(),
//       //     token: jsonVal['access_token'].toString()));
//       // pref.setString('Bearer', bearerToken[0].token);
//       // await getUserDetails();

//       result = 'true';
//     } else if (respon.statusCode == 422) {
//       debugPrint(respon.body);
//       var error = jsonDecode(respon.body)['errors'];
//       result = error[error.keys.toList()[0]]
//           .toString()
//           .replaceAll('[', '')
//           .replaceAll(']', '')
//           .toString();
//     } else {
//       debugPrint(respon.body);
//       result = jsonDecode(respon.body)['message'];
//     }
//     return result;
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//     }
//   }
// }
// //update referral code

updateReferral() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/update/user/referral'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"refferal_code": referralCode}));
            develper.log("updateReferral ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'true';
      } else {
        debugPrint(response.body);
        result = 'false';
      }
    } else {
      debugPrint(response.body);
      result = 'false';
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//call firebase otp

otpCall() async {
  dynamic result;
  try {
    var otp = await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
    result = otp;
    develper.log("otp ${otp}== ${result}");
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no Internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}


// verify user already exist

verifyUser(String number) async {
  dynamic val;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/user/validate-mobile-for-login'),
        body: {"mobile": number});
develper.log("verify USer ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      val = jsonDecode(response.body)['success'];

      if (val == true) {
        var check = await userLogin();
        if (check == true) {
          var uCheck = await getUserDetails();
          val = uCheck;
        } else {
          val = false;
        }
      } else {
        val = false;
      }
    } else {
      debugPrint(response.body);
      val = false;
    }
    return val;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//user login
userLogin({String? name, String? email, String? password,}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/user/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
        "name":name,
        "email":email,
        "password":password,
        "password_confirmation":password,
        "country":"+91",
        "device_token":fcm,
        "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
        // "service_location_id":"hbdfhfuhf32",
        }));

        develper.log("USerLOgin ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      develper.log("userLogin second ${jsonVal}===${response.statusCode}");
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else if(result == false) {
      debugPrint(response.body);
      result = true;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// forgot password
forgotPassword({
  String? email,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/password/forgot'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
        }));
        develper.log("Forget password ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      develper.log(" Forget Password ${jsonVal}===${response.statusCode}");
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// reset password
resetPassword({
  String? email,
  String? password,
  String? confirmPassword,
  String? otp,
}) async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/password/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "token":fcm,
          "email":email,
          "password":password,
          "password_confirmation":confirmPassword,
          "otp":otp,
        }));
        develper.log("reset Password ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      develper.log("resetPassword ${jsonVal}===${response.statusCode}");
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

Map<String, dynamic>  userDetails = {};
List favAddress = [];
List tripStops = [];

//user current state
getUserDetails() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${bearerToken[0].token}'
      },
    );

    develper.log("get USer Details ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      userDetails =
          Map<String, dynamic>.from(jsonDecode(response.body)['data']);
        
          develper.log("${response.body}get User Details");
      favAddress = userDetails['favouriteLocations']['data'];
      sosData = userDetails['sos']['data'];

      if (userDetails['onTripRequest'] != null) {
        if (userRequestData != userDetails['onTripRequest']['data']) {
          // audioPlayer.play(audio);
        }
        addressList.clear();
        userRequestData = userDetails['onTripRequest']['data'];
        develper.log("get USer ${userDetails} ${response.statusCode}");
        if (userRequestData['transport_type'] == 'taxi') {
          choosenTransportType = 0;
        } else {
          choosenTransportType = 1;
        }
        tripStops =
            userDetails['onTripRequest']['data']['requestStops']['data'];
        addressList.add(AddressList(
            id: '1',
            type: 'pickup',
            address: userRequestData['pick_address'],
            latlng: LatLng(
                userRequestData['pick_lat'], userRequestData['pick_lng']),
            name: userRequestData['pickup_poc_name'],
            number: userRequestData['pickup_poc_mobile'],
            instructions: userRequestData['pickup_poc_instruction']));

        if (tripStops.isNotEmpty) {
          for (var i = 0; i < tripStops.length; i++) {
            addressList.add(AddressList(
                id: (i + 2).toString(),
                type: 'drop',
                address: tripStops[i]['address'],
                latlng:
                    LatLng(tripStops[i]['latitude'], tripStops[i]['longitude']),
                name: tripStops[i]['poc_name'],
                number: tripStops[i]['poc_mobile'],
                instructions: tripStops[i]['poc_instruction']));
          }
        } else if (userDetails['onTripRequest']['data']['is_rental'] != true &&
            userRequestData['drop_lat'] != null) {
          addressList.add(AddressList(
              id: '2',
              type: 'drop',
              address: userRequestData['drop_address'],
              latlng: LatLng(
                  userRequestData['drop_lat'], userRequestData['drop_lng']),
              name: userRequestData['drop_poc_name'],
              number: userRequestData['drop_poc_mobile'],
              instructions: userRequestData['drop_poc_instruction']));
        }
        if (userRequestData['accepted_at'] != null) {
          getCurrentMessages();
        }

        if (userRequestData['is_completed'] == 0) {
          if (rideStreamUpdate == null ||
              rideStreamUpdate?.isPaused == true ||
              rideStreamStart == null ||
              rideStreamStart?.isPaused == true) {
            streamRide();
          }
        } else {
          if (rideStreamUpdate != null ||
              rideStreamUpdate?.isPaused == false ||
              rideStreamStart != null ||
              rideStreamStart?.isPaused == false) {
            rideStreamUpdate?.cancel();
            rideStreamUpdate = null;
            rideStreamStart?.cancel();
            rideStreamStart = null;
          }
        }
        valueNotifierHome.incrementNotifier();
        valueNotifierBook.incrementNotifier();
      } else if (userDetails['metaRequest'] != null) {
        userRequestData = userDetails['metaRequest']['data'];
        tripStops = userDetails['metaRequest']['data']['requestStops']['data'];
        addressList.add(AddressList(
            id: '1',
            type: 'pickup',
            address: userRequestData['pick_address'],
            latlng: LatLng(
                userRequestData['pick_lat'], userRequestData['pick_lng']),
            name: userRequestData['pickup_poc_name'],
            number: userRequestData['pickup_poc_mobile'],
            instructions: userRequestData['pickup_poc_instruction']));

        if (tripStops.isNotEmpty) {
          for (var i = 0; i < tripStops.length; i++) {
            addressList.add(AddressList(
                id: (i + 2).toString(),
                type: 'drop',
                address: tripStops[i]['address'],
                latlng:
                    LatLng(tripStops[i]['latitude'], tripStops[i]['longitude']),
                name: tripStops[i]['poc_name'],
                number: tripStops[i]['poc_mobile'],
                instructions: tripStops[i]['poc_instruction']));
          }
        } else if (userDetails['metaRequest']['data']['is_rental'] != true &&
            userRequestData['drop_lat'] != null) {
          addressList.add(AddressList(
              id: '2',
              type: 'drop',
              address: userRequestData['drop_address'],
              latlng: LatLng(
                  userRequestData['drop_lat'], userRequestData['drop_lng']),
              name: userRequestData['drop_poc_name'],
              number: userRequestData['drop_poc_mobile'],
              instructions: userRequestData['drop_poc_instruction']));
        }

        if (userRequestData['transport_type'] == 'taxi') {
          choosenTransportType = 0;
        } else {
          choosenTransportType = 1;
        }

        if (requestStreamStart == null ||
            requestStreamStart?.isPaused == true ||
            requestStreamEnd == null ||
            requestStreamEnd?.isPaused == true) {
          streamRequest();
        }
        valueNotifierHome.incrementNotifier();
        valueNotifierBook.incrementNotifier();
      } else {
        // if (userRequestData.isNotEmpty) {
        //   audioPlayer.play(audio);
        // }
        chatList.clear();
        userRequestData = {};
        requestStreamStart?.cancel();
        requestStreamEnd?.cancel();
        rideStreamUpdate?.cancel();
        rideStreamStart?.cancel();
        requestStreamEnd = null;
        requestStreamStart = null;
        rideStreamUpdate = null;
        rideStreamStart = null;
        valueNotifierHome.incrementNotifier();
        valueNotifierBook.incrementNotifier();
      }
      if (userDetails['active'] == false) {
        isActive = 'false';
      } else {
        isActive = 'true';
      }
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

class BearerClass {
  final String type;
  final String token;
  BearerClass({required this.type, required this.token});

  BearerClass.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        token = json['token'];

  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

Map<String, dynamic> driverReq = {};

class ValueNotifying {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifier = ValueNotifying();

class ValueNotifyingHome {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingKey {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingNotification {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifyingHome valueNotifierHome = ValueNotifyingHome();
ValueNotifyingKey valueNotifierKey = ValueNotifyingKey();
ValueNotifyingNotification valueNotifierNotification =
    ValueNotifyingNotification();

class ValueNotifyingBook {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifyingBook valueNotifierBook = ValueNotifyingBook();

//sound
AudioCache audioPlayer = AudioCache();
AudioPlayer audioPlayers = AudioPlayer();

//get reverse geo coding

var pickupAddress = '';
var dropAddress = '';

geoCoding(double lat, double lng) async {
  dynamic result;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'));

        develper.log("geoCoding  ${response.body}===${response.statusCode}");

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body);
      result = val['results'][0]['formatted_address'];
      develper.log("geo Coding ${val}===${result}");
    } else {
      debugPrint(response.body);
      result = '';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//lang
getlangid() async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/update-my-lang'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${bearerToken[0].token}',
    }, body: {
      'lang': choosenLanguage,
    });
    develper.log("getlangid ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
      develper.log("getLangid  ${response.body}===${response.statusCode}");
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get address auto fill data
List storedAutoAddress = [];
List addAutoFill = [];

getAutoAddress(input, sessionToken, lat, lng) async {
  dynamic response;
  var countryCode = userDetails['country_code'];
  try {
    if (userDetails['country_code'] == null) {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&key=$mapkey&sessiontoken=$sessionToken'));
    } else {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&location=$lat%2C$lng&radius=2000&components=country:$countryCode&key=$mapkey&sessiontoken=$sessionToken'));
    }

    develper.log("getAuto Address ${response}====");
    if (response.statusCode == 200) {
      develper.log("get Auto Address ${response.body}===${response.statusCode}");
      addAutoFill = jsonDecode(response.body)['predictions'];
      // ignore: avoid_function_literals_in_foreach_calls
      addAutoFill.forEach((element) {
        if (storedAutoAddress
            .where((e) =>
                e['description'].toString().toLowerCase() ==
                element['description'].toString().toLowerCase())
            .isEmpty) {
          storedAutoAddress.add(element);
        }
      });
      pref.setString('autoAddress', jsonEncode(storedAutoAddress).toString());
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//geocodeing location

geoCodingForLatLng(placeid) async {
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeid&key=$mapkey'));

        develper.log("geoCoding For Latlng ${response.body}===${response.statusCode}");

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body)['result']['geometry']['location'];
      center = LatLng(val['lat'], val['lng']);
      develper.log("geo Coding For LAt lng ${val}===${center}");
    } else {
      debugPrint(response.body);
    }
    return center;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//pickup drop address list

class AddressList {
  String address;
  LatLng latlng;
  String id;
  dynamic type;
  dynamic name;
  dynamic number;
  dynamic instructions;

  AddressList(
      {required this.id,
      required this.address,
      required this.latlng,
      this.type,
      this.name,
      this.number,
      this.instructions});
}

//get polylines

List<LatLng> polyList = [];

getPolylines() async {
  polyList.clear();
  String pickLat = '';
  String pickLng = '';
  String dropLat = '';
  String dropLng = '';
  // if (userRequestData.isEmpty) {
  //   pickLat = addressList
  //       .firstWhere((element) => element.type == 'pickup')
  //       .latlng
  //       .latitude
  //       .toString();
  //   pickLng = addressList
  //       .firstWhere((element) => element.type == 'pickup')
  //       .latlng
  //       .longitude
  //       .toString();
  //   dropLat = addressList
  //       .firstWhere((element) => element.type == 'drop')
  //       .latlng
  //       .latitude
  //       .toString();
  //   dropLng = addressList
  //       .firstWhere((element) => element.type == 'drop')
  //       .latlng
  //       .longitude
  //       .toString();
  // } else {
  //   pickLat = userRequestData['pick_lat'].toString();
  //   pickLng = userRequestData['pick_lng'].toString();
  //   dropLat = userRequestData['drop_lat'].toString();
  //   dropLng = userRequestData['drop_lng'].toString();
  // }
  for (var i = 1; i < addressList.length; i++) {
    pickLat = addressList[i - 1].latlng.latitude.toString();
    pickLng = addressList[i - 1].latlng.longitude.toString();
    dropLat = addressList[i].latlng.latitude.toString();
    dropLng = addressList[i].latlng.longitude.toString();

    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
     develper.log("get Polylines ${response.body}===${response.statusCode} ===$response");
     
      if (response.statusCode == 200) {
        var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']
            ['points'];
        decodeEncodedPolyline(steps);
        develper.log("get POlylines ${steps}");
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  }
  return polyList;
}

//polyline decode

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  polyline.clear();

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }

  polyline.add(
    Polyline(
        polylineId: const PolylineId('1'),
        color: const Color(0xffFD9898),
        visible: true,
        width: 4,
        points: polyList),
  );
  valueNotifierBook.incrementNotifier();
  return poly;
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

//get goods list
List goodsTypeList = [];

getGoodsList() async {
  dynamic result;
  goodsTypeList.clear();
  try {
    var response = await http.get(Uri.parse('${url}api/v1/common/goods-types'));
    develper.log("getGoodsList ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      goodsTypeList = jsonDecode(response.body)['data'];
      valueNotifierBook.incrementNotifier();
      result = 'success';
      develper.log("get Good List ${goodsTypeList}===${valueNotifierBook}===$result");
    } else {
      debugPrint(response.body);
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//drop stops list
List<DropStops> dropStopList = <DropStops>[];

class DropStops {
  String order;
  double latitude;
  double longitude;
  String pocName;
  String pocNumber;
  dynamic pocInstruction;
  String address;
  DropStops(
      {required this.order,
      required this.latitude,
      required this.longitude,
      required this.pocName,
      required this.pocNumber,
      required this.pocInstruction,
      required this.address});

  Map<String, dynamic> toJson() => {
        'order': order,
        'latitude': latitude,
        'longitude': longitude,
        'poc_name': pocName,
        'poc_mobile': pocNumber,
        'poc_instruction': pocInstruction,
        'address': address,
      };
}

List etaDetails = [];

// String bearertoken ="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIyIiwianRpIjoiZjIzNzk3ZWRmNzk1YjRhN2YzN2Q4MTQwNTM5MDhlZjNlOGQ3OTdkNGRmMTM3NzdhMGMyZjEyMGIzZTVhMDgxNTJkNjk4MDA2NTcyZTE2ZDQiLCJpYXQiOjE3MTgwOTY4MTYuNDY2ODMsIm5iZiI6MTcxODA5NjgxNi40NjY4MzMsImV4cCI6MTcxODk2MDgxNi40NTE1MTksInN1YiI6IjEyMyIsInNjb3BlcyI6W119.Bwa6PDFZd7GFsVxGx1Be09iODa4cqgqVKLkrzj8k8n_UNXABxgmqUZhJPvydicm3u5t4-9tlqs2OkcINnUnNNEnt6fur14n1pXlZWovxCerc3U6DMLdyepbYzjq41Al-S_UFkR59WoOAqBYyVwi-BFL8w4vmwfcrLVsSLaWci-CqgRt37sjIgwrHU-uIV-q0LKYr958VDbKNZ0zMuLOU9Fb8kxv68TsfJ2d9MpnQ5tLzAo2iPEC8frfBRjPU5VScx31RHRI-n-YH-0u7xRba4oUjHMq0oz9uhHNuTC1VgvCqSx24xsSs7wNAiSQEl6nvGTwfSDx9zsr0kRuVySYzBDqh4bvwg9mozqQo22ULaS43Q5DM--MuXYQ896uBl7bfXNVLp9hGxDd4QHrl8fA-lZBuq_mwHdBxz6Q32_mnUjuftLHJhzyZqMWHZIQSOWjg0QHIUpbc4jyl_HfOEqR4VZ3MAIguKgvwoEu37fNYWMPX5nWALZG6HbgTCU3_4PKQI1Pp3noi4I0N9haek4T1fAiDrOZlw0bdiiEs69VeVVdSFez4nFLQdoZq9pxOeSs7xG_Dy6flerTb3QL4j-fri25HjmBKGb9zroXmsk6Eqg2lGWcyWl29Xk_FTtF23006P5JGqwvhiOSnXsay2UA61p_a73Do7xv3sHZAOkGzkO8";

//eta request
// car data this api show list of car service on user phone

etaRequest(bool smoking, bool pets, bool drinking, bool handicap) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body:
            (addressList.where((element) => element.type == 'drop').isNotEmpty)
                ? jsonEncode({
                    'pick_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lat']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .latitude,
                    'pick_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lng']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .longitude,
                    'drop_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['drop_lat']
                        : addressList
                            .lastWhere((e) => e.type == 'drop')
                            .latlng
                            .latitude,
                    'drop_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['drop_lng']
                        : addressList
                            .lastWhere((e) => e.type == 'drop')
                            .latlng
                            .longitude,
                    'ride_type': 1,
                    "smoking": smoking,
                    "pets": pets,
                    "drinking": drinking,
                    "handicaped": handicap,
                    'transport_type':
                        (choosenTransportType == 0) ? 'taxi' : 'delivery'
                  })
                : jsonEncode({
                    'pick_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lat']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .latitude,
                    'pick_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lng']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .longitude,
                    'ride_type': 1,
                    "smoking": smoking,
                    "pets": pets,
                    "drinking": drinking,
                    "handicaped": handicap
                  }));
develper.log("etaRequest ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      print('eta started');

      print('eta request ' + response.body);
      etaDetails = jsonDecode(response.body)['data'];
      if (!smoking || !pets || !drinking || !handicap) {
        // etaDetails.removeWhere((item) {
        //   return (smoking || item['smoking'] == 0) &&
        //       (pets || item['pets'] == 0) &&
        //       (drinking || item['drinking'] == 0) &&
        //       (handicap || item['handicaped'] == 0);
        // });
        etaDetails = etaDetails.where((item) {
          return (!smoking || item['smoking'] == 1) &&
              (!pets || item['pets'] == 1) &&
              (!drinking || item['drinking'] == 1) &&
              (!handicap || item['handicaped'] == 1);
        }).toList();
      } else {
        etaDetails;
      }

      print("filterrrrr data list $etaDetails");
      choosenVehicle =
          etaDetails.indexWhere((element) => element['is_default'] == true);
      result = true;
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] ==
          "service not available with this location") {
        serviceNotAvailable = true;
      }
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// etaRequestFilter(bool smoking, bool pets, bool drinking, bool handicap) async {
//   dynamic result;
//   try {
//     var dddd;

//     var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
//         headers: {
//           'Authorization': 'Bearer ${bearerToken[0].token}',
//           'Content-Type': 'application/json',
//         },
//         body:
//             (addressList.where((element) => element.type == 'drop').isNotEmpty)
//                 ? jsonEncode({
//                     'pick_lat': (userRequestData.isNotEmpty)
//                         ? userRequestData['pick_lat']
//                         : addressList
//                             .firstWhere((e) => e.type == 'pickup')
//                             .latlng
//                             .latitude,
//                     'pick_lng': (userRequestData.isNotEmpty)
//                         ? userRequestData['pick_lng']
//                         : addressList
//                             .firstWhere((e) => e.type == 'pickup')
//                             .latlng
//                             .longitude,
//                     'drop_lat': (userRequestData.isNotEmpty)
//                         ? userRequestData['drop_lat']
//                         : addressList
//                             .lastWhere((e) => e.type == 'drop')
//                             .latlng
//                             .latitude,
//                     'drop_lng': (userRequestData.isNotEmpty)
//                         ? userRequestData['drop_lng']
//                         : addressList
//                             .lastWhere((e) => e.type == 'drop')
//                             .latlng
//                             .longitude,
//                     'ride_type': 1,
//                     'transport_type':
//                         (choosenTransportType == 0) ? 'taxi' : 'delivery',
//                     "smoking": smoking,
//                     "pets": pets,
//                     "drinking": drinking,
//                     "handicaped": handicap
//                   })
//                 : jsonEncode({
//                     'pick_lat': (userRequestData.isNotEmpty)
//                         ? userRequestData['pick_lat']
//                         : addressList
//                             .firstWhere((e) => e.type == 'pickup')
//                             .latlng
//                             .latitude,
//                     'pick_lng': (userRequestData.isNotEmpty)
//                         ? userRequestData['pick_lng']
//                         : addressList
//                             .firstWhere((e) => e.type == 'pickup')
//                             .latlng
//                             .longitude,
//                     'ride_type': 1,
//                     "smoking": smoking,
//                     "pets": pets,
//                     "drinking": drinking,
//                     "handicaped": handicap
//                   }));

//     if (response.statusCode == 200) {
//       print('eta started');
//       print('smoking $smoking');
//       print('drinking $drinking');
//       print('handicap $handicap');
//       print('handicap $pets');

//       print('eta request ' + response.body);
//       etaDetails = jsonDecode(response.body)['data'];
//       //  etaRequest();

//       //  List filteredData
//       etaDetails = etaDetails
//           .where((element) =>
//               element['smoking'] == 1 && smoking == true ||
//               element['pets'] == 1 && pets == true ||
//               element['drinking'] == 1 && drinking == true ||
//               element['handicaped'] == 1 && handicap == true)
//           .toList();

//       choosenVehicle =
//           etaDetails.indexWhere((element) => element['is_default'] == true);
//       result = true;
//       valueNotifierBook.incrementNotifier();
//     } else {
//       debugPrint(response.body);
//       if (jsonDecode(response.body)['message'] ==
//           "service not available with this location") {
//         serviceNotAvailable = true;
//       }
//       result = false;
//     }
//     return result;
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//     }
//   }
// }

etaRequestWithPromo() async {
  dynamic result;
  // etaDetails.clear();
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body:
            (addressList.where((element) => element.type == 'drop').isNotEmpty)
                ? jsonEncode({
                    'pick_lat': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .latitude,
                    'pick_lng': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .longitude,
                    'drop_lat': addressList
                        .firstWhere((e) => e.type == 'drop')
                        .latlng
                        .latitude,
                    'drop_lng': addressList
                        .firstWhere((e) => e.type == 'drop')
                        .latlng
                        .longitude,
                    'ride_type': 1,
                    'promo_code': promoCode
                  })
                : jsonEncode({
                    'pick_lat': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .latitude,
                    'pick_lng': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .longitude,
                    'ride_type': 1,
                    'promo_code': promoCode
                  }));
develper.log("etaRequestWith Promo ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      promoCode = '';
      promoStatus = 1;
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      promoStatus = 2;
      promoCode = '';
      valueNotifierBook.incrementNotifier();

      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//rental eta request

rentalEta() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/list-packages'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'pick_lat': (userRequestData.isNotEmpty)
                  ? userRequestData['pick_lat']
                  : addressList
                      .firstWhere((e) => e.type == 'pickup')
                      .latlng
                      .latitude,
              'pick_lng': (userRequestData.isNotEmpty)
                  ? userRequestData['pick_lng']
                  : addressList
                      .firstWhere((e) => e.type == 'pickup')
                      .latlng
                      .longitude,
              'transport_type':
                  (choosenTransportType == 0) ? 'taxi' : 'delivery'
            }));
            develper.log("rentalEta ${response.body}===${response.statusCode}");

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      rentalOption = etaDetails[0]['typesWithPrice']['data'];
      rentalChoosenOption = 0;
      result = true;
      valueNotifierBook.incrementNotifier();
    } else {
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

rentalRequestWithPromo() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/list-packages'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'pick_lat': addressList
                  .firstWhere((e) => e.type == 'pickup')
                  .latlng
                  .latitude,
              'pick_lng': addressList
                  .firstWhere((e) => e.type == 'pickup')
                  .latlng
                  .longitude,
              'ride_type': 1,
              'promo_code': promoCode
            }));

            develper.log("rental RequestWith Promo ${response.body}===${response.statusCode}");

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      rentalOption = etaDetails[0]['typesWithPrice']['data'];
      rentalChoosenOption = 0;
      promoCode = '';
      promoStatus = 1;
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      promoStatus = 2;
      promoCode = '';
      valueNotifierBook.incrementNotifier();

      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//calculate distance

calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

Map<String, dynamic > userRequestData = {};

//create request

createRequest(value, api) async {
  dynamic result;
  try {
    develper.log('user token ${bearerToken[0].token}');
    print('createddd !  $value');
    var response = await http.post(Uri.parse('$url$api'),

        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: value);
    print('value$url$api');
        develper.log("create Request ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      userRequestData = jsonDecode(response.body)['data'];
      print('drivers details $userRequestData');
      streamRequest();
      result = 'success';

      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

// //create request with promo code

// createRequestWithPromo() async {
//   dynamic result;
//   try {
//     var response = await http.post(Uri.parse('${url}api/v1/request/create'),
//         headers: {
//           'Authorization': 'Bearer ${bearerToken[0].token}',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'pick_lat':
//               addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
//           'pick_lng':
//               addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
//           'drop_lat':
//               addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
//           'drop_lng':
//               addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
//           'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
//           'ride_type': 1,
//           'payment_opt': (etaDetails[choosenVehicle]['payment_type']
//                       .toString()
//                       .split(',')
//                       .toList()[payingVia] ==
//                   'card')
//               ? 0
//               : (etaDetails[choosenVehicle]['payment_type']
//                           .toString()
//                           .split(',')
//                           .toList()[payingVia] ==
//                       'cash')
//                   ? 1
//                   : 2,
//           'pick_address':
//               addressList.firstWhere((e) => e.id == 'pickup').address,
//           'drop_address': addressList.firstWhere((e) => e.id == 'drop').address,
//           'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
//           'request_eta_amount': etaDetails[choosenVehicle]['total']
//         }));
//     if (response.statusCode == 200) {
//       userRequestData = jsonDecode(response.body)['data'];
//       result = 'success';
//       streamRequest();
//       valueNotifierBook.incrementNotifier();
//     } else {
//       debugPrint(response.body);
//       if (jsonDecode(response.body)['message'] == 'no drivers available') {
//         noDriverFound = true;
//       } else {
//         tripReqError = true;
//       }

//       result = 'failure';
//       valueNotifierBook.incrementNotifier();
//     }
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//       result = 'no internet';
//     }
//   }
//   return result;
// }

//create request

createRequestLater(val, api) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('$url$api'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: val);

        develper.log("CreateRequest Later ${response.body}===${response.statusCode}");
        print('vale$url$api');
    if (response.statusCode == 200) {
      result = 'success';
      streamRequest();
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//create request with promo code

createRequestLaterPromo() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
          'ride_type': 1,
          'payment_opt': (etaDetails[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (etaDetails[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'drop_address': addressList.firstWhere((e) => e.id == 'drop').address,
          'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': etaDetails[choosenVehicle]['total']
        }));

        develper.log("Create Request later Promo ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      myMarkers.clear();
      streamRequest();
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }

  return result;
}

//create rental request

createRentalRequest() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 1,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));

        develper.log("CreateRentalRequest ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      userRequestData = jsonDecode(response.body)['data'];
      streamRequest();
      result = 'success';

      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

createRentalRequestWithPromo() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 1,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));
        develper.log("create Rental Request With Promo ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      userRequestData = jsonDecode(response.body)['data'];
      streamRequest();
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        debugPrint(response.body);
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

createRentalRequestLater() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 1,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));
        develper.log("Create Retal Request Later ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
      streamRequest();
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

createRentalRequestLaterPromo() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 1,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
        }));
        develper.log("Create Rental Request Later Promo ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      myMarkers.clear();
      streamRequest();
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        debugPrint(response.body);
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }

  return result;
}

List<RequestCreate> createRequestList = <RequestCreate>[];

class RequestCreate {
  dynamic pickLat;
  dynamic pickLng;
  dynamic dropLat;
  dynamic dropLng;
  dynamic vehicleType;
  dynamic rideType;
  dynamic paymentOpt;
  dynamic pickAddress;
  dynamic dropAddress;
  dynamic promoCodeId;

  RequestCreate(
      {this.pickLat,
      this.pickLng,
      this.dropLat,
      this.dropLng,
      this.vehicleType,
      this.rideType,
      this.paymentOpt,
      this.pickAddress,
      this.dropAddress,
      this.promoCodeId});

  Map<String, dynamic> toJson() => {
        'pick_lat': pickLat,
        'pick_lng': pickLng,
        'drop_lat': dropLat,
        'drop_lng': dropLng,
        'vehicle_type': vehicleType,
        'ride_type': rideType,
        'payment_opt': paymentOpt,
        'pick_address': pickAddress,
        'drop_address': dropAddress,
        'promocode_id': promoCodeId
      };
}

//user cancel request

cancelRequest() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/cancel'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'request_id': userRequestData['id']}));
        develper.log("Cancel Request ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      userCancelled = true;
      FirebaseDatabase.instance
          .ref('requests')
          .child(userRequestData['id'])
          .update({'cancelled_by_user': true});
      userRequestData = {};
      if (requestStreamStart?.isPaused == false ||
          requestStreamEnd?.isPaused == false) {
        requestStreamStart?.cancel();
        requestStreamEnd?.cancel();
        requestStreamStart = null;
        requestStreamEnd = null;
      }
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

cancelLaterRequest(val) async {
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/cancel'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'request_id': val}));
        develper.log("Cancel LAter Request ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      userRequestData = {};
      if (requestStreamStart?.isPaused == false ||
          requestStreamEnd?.isPaused == false) {
        requestStreamStart?.cancel();
        requestStreamEnd?.cancel();
        requestStreamStart = null;
        requestStreamEnd = null;
      }
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//user cancel request with reason

cancelRequestWithReason(reason) async {
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/cancel'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'request_id': userRequestData['id'], 'reason': reason}));
            develper.log("cancel Request With Reason ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      cancelRequestByUser = true;
      FirebaseDatabase.instance
          .ref('requests/${userRequestData['id']}')
          .update({'cancelled_by_user': true});
      userRequestData = {};
      if (rideStreamUpdate?.isPaused == false ||
          rideStreamStart?.isPaused == false) {
        rideStreamUpdate?.cancel();
        rideStreamUpdate = null;
        rideStreamStart?.cancel();
        rideStreamStart = null;
      }
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//making call to user

makingPhoneCall(phnumber) async {
  var mobileCall = 'tel:$phnumber';
  if (await canLaunch(mobileCall)) {
    await launch(mobileCall);
  } else {
    throw 'Could not launch $mobileCall';
  }
}

//cancellation reason
List cancelReasonsList = [];
cancelReason(reason) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(
          '${url}api/v1/common/cancallation/reasons?arrived=$reason?transport_type=${userRequestData['transport_type']}'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json',
      },
    );
develper.log("cancel Reason ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      cancelReasonsList = jsonDecode(response.body)['data'];
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

List<CancelReasonJson> cancelJson = <CancelReasonJson>[];

class CancelReasonJson {
  dynamic requestId;
  dynamic reason;

  CancelReasonJson({this.requestId, this.reason});

  Map<String, dynamic> toJson() {
    return {'request_id': requestId, 'reason': reason};
  }
}

//add user rating

userRating() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/rating'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': userRequestData['id'],
          'rating': review,
          'comment': feedback
        }));
        develper.log("userRating ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getUserDetails();
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//class for realtime database driver data

class NearByDriver {
  double bearing;
  String g;
  String id;
  List l;
  String updatedAt;

  NearByDriver(
      {required this.bearing,
      required this.g,
      required this.id,
      required this.l,
      required this.updatedAt});

  factory NearByDriver.fromJson(Map<String, dynamic> json) {
    return NearByDriver(
        id: json['id'],
        bearing: json['bearing'],
        g: json['g'],
        l: json['l'],
        updatedAt: json['updated_at']);
  }
}

//add favourites location

addFavLocation(lat, lng, add, name) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/user/add-favourite-location'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'pick_lat': lat,
          'pick_lng': lng,
          'pick_address': add,
          'address_name': name
        }));

        develper.log("add Fav Location ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = true;
      await getUserDetails();
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//sos data
List sosData = [];

getSosData(lat, lng) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/sos/list/$lat/$lng'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    develper.log("get SOS Data ${response.body}===${response.statusCode}");

    if (response.statusCode == 200) {
      sosData = jsonDecode(response.body)['data'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//sos admin notification

notifyAdmin() async {
  var db = FirebaseDatabase.instance.ref();
  // var result;

  try {
    await db.child('SOS/${userRequestData['id']}').update({
      "is_driver": "0",
      "is_user": "1",
      "req_id": userRequestData['id'],
      "serv_loc_id": userRequestData['service_location_id'],
      "updated_at": ServerValue.timestamp
    });
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return true;
}

//get current ride messages

List chatList = [];

getCurrentMessages() async {
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/request/chat-history/${userRequestData['id']}'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    develper.log("get Current Message ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        if (chatList.where((element) => element['from_type'] == 2).length !=
            jsonDecode(response.body)['data']
                .where((element) => element['from_type'] == 2)
                .length) {
          // audioPlayer.play(audio);
        }
        chatList = jsonDecode(response.body)['data'];
        valueNotifierBook.incrementNotifier();
      }
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//send chat

sendMessage(chat) async {
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/send'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body:
            jsonEncode({'request_id': userRequestData['id'], 'message': chat}));

            develper.log("sendMessage ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getCurrentMessages();
      FirebaseDatabase.instance
          .ref('requests/${userRequestData['id']}')
          .update({'message_by_user': chatList.length});
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//message seen

messageSeen() async {
  var response = await http.post(Uri.parse('${url}api/v1/request/seen'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': userRequestData['id']}));
      develper.log("Message Seen ${response.body}===${response.statusCode}");
  if (response.statusCode == 200) {
    getCurrentMessages();
  } else {
    debugPrint(response.body);
  }
}

//add sos

addSos(name, number) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/common/sos/store'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'name': name, 'number': number}));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//remove sos

deleteSos(id) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/common/sos/delete/$id'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    develper.log("deleteSos ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//open url in browser

openBrowser(browseUrl) async {
  if (await canLaunch(browseUrl)) {
    await launch(browseUrl);
  } else {
    throw 'Could not launch $browseUrl';
  }
}

//get faq
List faqData = [];

getFaqData(lat, lng) async {
  dynamic result;
  try {
    var response = await http
        .get(Uri.parse('${url}api/v1/common/faq/list/$lat/$lng'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    develper.log("getFaqData ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      faqData = jsonDecode(response.body)['data'];
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

//remove fav address

removeFavAddress(id) async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/user/delete-favourite-location/$id'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        });
        develper.log("RemoveFavAddress ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get user referral

Map<String, dynamic> myReferralCode = {};
getReferral() async {
  dynamic result;
  try {
    var response =
        await http.get(Uri.parse('${url}api/v1/get/referral'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    develper.log("get Referral ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
      myReferralCode = jsonDecode(response.body)['data'];
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//user logout

userLogout() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/logout'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    develper.log("UserLOgout  ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      pref.remove('Bearer');

      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//request history
List myHistory = [];
Map<String, dynamic> myHistoryPage = {};

getHistory(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("getHistory ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      myHistory = jsonDecode(response.body)['data'];
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

getHistoryPages(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("get History Pages ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        myHistory.add(element);
      });
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

//get wallet history

Map<String, dynamic> walletBalance = {};
List walletHistory = [];
Map<String, dynamic> walletPages = {};

getWalletHistory() async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("getWallet History ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      walletBalance = jsonDecode(response.body);
      walletHistory = walletBalance['wallet_history']['data'];
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

getWalletHistoryPage(page) async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history?page=$page'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("getWallet History Page ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      List list = walletBalance['wallet_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        walletHistory.add(element);
      });
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

//get client token for braintree

getClientToken() async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/client/token'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("get Client token ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//stripe payment

Map<String, dynamic> stripeToken = {};

getStripePayment(money) async {
  dynamic results;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/stripe/intent'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
            develper.log("get Stripe Payment ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      results = 'success';
      stripeToken = jsonDecode(response.body)['data'];
    } else {
      debugPrint(response.body);
      results = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

//stripe add money

addMoneyStripe(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/stripe/add/money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
            develper.log("add Money Stripe ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//stripe pay money

payMoneyStripe(nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/stripe/make-payment-for-ride'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'request_id': userRequestData['id'], 'payment_id': nonce}));
            develper.log("pay Money Stripe ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//paystack payment
Map<String, dynamic> paystackCode = {};

getPaystackPayment(body) async {
  dynamic results;
  paystackCode.clear();
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/paystack/initialize'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: body);
            develper.log("get Pay stack Payment ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == false) {
        results = jsonDecode(response.body)['message'];
      } else {
        // printWrapped(response.body);
        results = 'success';
        paystackCode = jsonDecode(response.body)['data'];
      }
    } else {
      debugPrint(response.body);
      results = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

addMoneyPaystack(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/paystack/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
            develper.log("add Money Pay Satck ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      paystackCode.clear();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//flutterwave

addMoneyFlutterwave(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/flutter-wave/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
            develper.log("add Mony FlutterWave ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//razorpay

addMoneyRazorpay(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/razerpay/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
            develper.log("paymentGateway ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//cashfree

Map<String, dynamic> cftToken = {};

getCfToken(money, currency) async {
  cftToken.clear();
  cfSuccessList.clear();
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/generate-cftoken'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'order_amount': money, 'order_currency': currency}));
        develper.log("getCF Token ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == 'OK') {
        cftToken = jsonDecode(response.body);
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String, dynamic> cfSuccessList = {};

cashFreePaymentSuccess() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/add-money-to-wallet-webhooks'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'orderId': cfSuccessList['orderId'],
          'orderAmount': cfSuccessList['orderAmount'],
          'referenceId': cfSuccessList['referenceId'],
          'txStatus': cfSuccessList['txStatus'],
          'paymentMode': cfSuccessList['paymentMode'],
          'txMsg': cfSuccessList['txMsg'],
          'txTime': cfSuccessList['txTime'],
          'signature': cfSuccessList['signature']
        }));

        develper.log("cash free Payment Success ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
        await getWalletHistory();
        await getUserDetails();
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//edit user profile

updateProfile(name, email ,imagePath) async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
    response.files
        .add(await http.MultipartFile.fromPath('profile_picture', imageFile!.path));
    response.fields['email'] = email;
    response.fields['name'] = name;
    if (imagePath.isNotEmpty) {
      response.files.add(await http.MultipartFile.fromPath(
        "profile_picture",
        imagePath,
      ));
    }
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    develper.log("update Profile ${request.statusCode}===${val}");
    if (request.statusCode == 200) {
      result = 'success';
      develper.log("updateProfile ${result}===${respon.body} ${respon.statusCode}");
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(val);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

updateProfileWithoutImage(name, email) async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    develper.log("update Profile Without Image ${request.statusCode}===${request.stream}");
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(val);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

//internet true
internetTrue() {
  internet = true;
  valueNotifierHome.incrementNotifier();
}

//make complaint

List generalComplaintList = [];
getGeneralComplaint(type) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/complaint-titles?complaint_type=$type'),
      headers: {'Authorization': 'Bearer ${bearerToken[0].token}'},
    );
    develper.log("get General complanint ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      generalComplaintList = jsonDecode(response.body)['data'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeGeneralComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
            }));
            develper.log("make General Complaint ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeRequestComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
              'request_id': myHistory[selectedHistory]['id']
            }));
            develper.log("make Rquest Complaint ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//requestStream
StreamSubscription<DatabaseEvent>? requestStreamStart;
StreamSubscription<DatabaseEvent>? requestStreamEnd;
bool userCancelled = false;

streamRequest() {
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamUpdate?.cancel();
  rideStreamStart?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamUpdate = null;
  rideStreamStart = null;
  requestStreamStart = FirebaseDatabase.instance
      .ref('request-meta')
      .child(userRequestData['id'])
      .onChildRemoved
      .handleError((onError) {
    requestStreamStart?.cancel();
  }).listen((event) async {
    getUserDetails();
    requestStreamEnd?.cancel();
    requestStreamStart?.cancel();
  });
}

StreamSubscription<DatabaseEvent>? rideStreamStart;
StreamSubscription<DatabaseEvent>? rideStreamUpdate;

streamRide() {
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamUpdate?.cancel();
  rideStreamStart?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamUpdate = null;
  rideStreamStart = null;
  rideStreamUpdate = FirebaseDatabase.instance
      .ref('requests/${userRequestData['id']}')
      .onChildChanged
      .handleError((onError) {
    rideStreamUpdate?.cancel();
  }).listen((DatabaseEvent event) async {
    if (event.snapshot.key.toString() == 'trip_start' ||
        event.snapshot.key.toString() == 'trip_arrived' ||
        event.snapshot.key.toString() == 'is_completed') {
      getUserDetails();
    } else if (event.snapshot.key.toString() == 'message_by_driver') {
      getCurrentMessages();
      develper.log("${event.snapshot.key}");
    } else if (event.snapshot.key.toString() == 'cancelled_by_driver') {
      requestCancelledByDriver = true;
      getUserDetails();
    }
  });

  rideStreamStart = FirebaseDatabase.instance
      .ref('requests/${userRequestData['id']}')
      .onChildAdded
      .handleError((onError) {
    rideStreamStart?.cancel();
  }).listen((DatabaseEvent event) async {
    if (event.snapshot.key.toString() == 'message_by_driver') {
      getCurrentMessages();
    } else if (event.snapshot.key.toString() == 'cancelled_by_driver') {
      requestCancelledByDriver = true;
      getUserDetails();
    }
  });
}

userDelete() async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/delete-user-account'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    develper.log("user Delete ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      pref.remove('Bearer');

      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//request notification
List notificationHistory = [];
Map<String, dynamic> notificationHistoryPage = {};

getnotificationHistory() async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("Get Notification History ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      notificationHistory = jsonDecode(response.body)['data'];
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getNotificationPages(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("getNotification Pages ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        notificationHistory.add(element);
      });
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//delete notification
deleteNotification(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/delete-notification/$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
        develper.log("Delete Notification ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      // notificationHistory = jsonDecode(response.body)['data'];
      // notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

sharewalletfun({mobile, role, amount}) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/transfer-money-from-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${bearerToken[0].token}',
        },
        body: jsonEncode({'mobile': mobile, 'role': role, 'amount': amount}));
        develper.log("Delete Notification ${response.body}===${response.statusCode}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}
