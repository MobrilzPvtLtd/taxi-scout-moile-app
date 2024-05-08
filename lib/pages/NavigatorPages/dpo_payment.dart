

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:location/location.dart';
import 'package:tagyourtaxi_driver/pages/login/get_started.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:dpo_standard/dpo.dart';
import 'package:dpo_standard/models/responses/charge_response.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translations/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

// ignore: must_be_immutable
class DPOPayment extends StatefulWidget {
String? Totalprice;
  DPOPayment({this.Totalprice, Key? key}) : super(key: key);

  @override
  State<DPOPayment> createState() => _DPOPaymentState();
}

class _DPOPaymentState extends State<DPOPayment> {
final urlController = TextEditingController();
final firstnameController = TextEditingController();
final lastnameController = TextEditingController();
final addressController = TextEditingController();
final cityController = TextEditingController();
final mobilenumberController = TextEditingController();
final emailController = TextEditingController();
String? paymentrilsss;
bool isLoading = false;

  void startLoader() {
    setState(() {
      isLoading = true;
    });

    // Wait for 2 seconds and then stop the loader
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  void initState() {
    print(':::::::::::::::${widget.Totalprice}');
   // payMoney();
    super.initState();
  }
 final url = 
  //" https://secure.3gdirectpay.com/payv3.php?ID=token";
      "https://secure.3gdirectpay.com/payv3.php?ID=E7045C50-E58C-492E-BB08-2A765C97F913";
  _handlePaymentInitialization() async {
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
      paymentUrl: paymentrilsss.toString(),
    );
print('url::::::::::::::::::${urlController.text}');
    final ChargeResponse response = await dpo.charge();
    if (response != null) {
      showLoading(response.status!);
      print("${response.toJson()}");
    } else {
      print("${response.toJson()}");
      showLoading("No Response!");
      Timer(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> showLoading(String message) {
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
 _onPressed() {
  
      _handlePaymentInitialization();
    
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(media.width * 0.05,
                          media.width * 0.05, media.width * 0.05, 0),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                child: Text('DPO Money',
                                 // languages[choosenLanguage]['text_addmoney'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Icon(Icons.arrow_back)))
                            ],
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                         Container(
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(    
                              controller: firstnameController,                        
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'First Name'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
      Container(
        margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(  
                              controller: lastnameController,                          
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'Last Name'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
      Container(
        margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(  
                              controller: addressController,                          
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'Address'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
      Container(
        margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(   
                              controller: cityController,                         
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'City'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
       Container(
        margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(   
                              keyboardType: TextInputType.number,
                              controller: mobilenumberController,                         
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'Mobile Number'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
       Container(
        margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(      
                              controller: emailController,                      
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: 'Email'),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
      Container(
        margin: EdgeInsets.only(top: 10,bottom: 50),
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding:  EdgeInsets.only(left: 10),
                            child: TextField(      readOnly: true,                      
                            decoration: InputDecoration(
                               border: InputBorder.none,
          focusedBorder: InputBorder.none,
                              hintText: widget.Totalprice),
                            ),
                          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
         
          ),
  
     ),
        isLoading
                ? CircularProgressIndicator() // Loader
                : SizedBox(), // Empty space when loader is not visible

      Button(
                                            onTap: ()  {
                                                // startLoader;
                                              paymentgetwayss();
                                           //   paymentgetways(widget.Totalprice.toString(),firstnameController.text,lastnameController.text,addressController.text,cityController.text,mobilenumberController.text,emailController.text,context);
                                             // _onPressed();
                                            
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_addmoney'],
                                            width: media.width * 0.4,
                                          ),
                         
                        ],
                      ),
                    ),
                   
                  
                
                  ],
                ),
              );
            }),
      ),
    );
  }
  paymentgetwayss() async {
 // bearerToken.clear();
 // dynamic result;
 dynamic result;
    try {
    var response =
        await http.post(Uri.parse('https://dumbadpo.appnexustech.in/api/v1/dpo_payment'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
                    "paymentAmount": widget.Totalprice.toString(),
      "paymentCurrency": 'TZS',
      "customerFirstName": firstnameController.text,
      "customerLastName": lastnameController.text,
      "customerAddress": addressController.text,
      "customerCity": cityController.text,
      'customerPhone': mobilenumberController.text,
      'customerEmail':emailController.text,
      'companyRef':'34TESTREFF'
            //  "refferal_code": referralCode
              }));
    if (response.statusCode == 200) {
        String jsonResponse = response.body;

  Map<String, dynamic> responseMap = json.decode(jsonResponse);
   if (responseMap['success'] == true) {
     paymentrilsss = responseMap['payment_url'];
    print('Payment URL: $paymentrilsss');
 _onPressed();
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
  // try {
  //   var token = await FirebaseMessaging.instance.getToken();
  //   var fcm = token.toString();
  //   final response =
  //       http.MultipartRequest('POST', Uri.parse('https://dumbadpo.appnexustech.in/api/v1/dpo_payment'));
  //   response.headers.addAll({'Content-Type': 'application/json', });
  //   // if (proImageFile1 != null) {
  //   //   response.files.add(
  //   //       await http.MultipartFile.fromPath('profile_picture', proImageFile1));
  //   // }
  //   response.fields.addAll({

  //   });
  //    if (response.s == 200) {
  //       String jsonResponse = response.body;

  // Map<String, dynamic> responseMap = json.decode(jsonResponse);
  //  if (responseMap['success'] == true) {
  //    paymentrils = responseMap['payment_url'];
  //   print('Payment URL: $paymentrils');
  //  // _onPressed(context);
  // } 

  // //   var request = await response.send();
  // //   var respon = await http.Response.fromStream(request);

  // //   if (respon.statusCode == 200) {
  // //     var jsonVal = jsonDecode(respon.body);
  // //       Map<String, dynamic> responseMap = json.decode(jsonVal);
  // //  if (responseMap['success'] == true) {
  // //    paymentrils = responseMap['payment_url'];
  // //   print('Payment URL: $paymentrils');
  // //  // _onPressed(context);
  // // } 

     

  //     result = 'true';
  //   } else if (respon.statusCode == 422) {
  //     debugPrint(respon.body);
  //     var error = jsonDecode(respon.body)['errors'];
  //     result = error[error.keys.toList()[0]]
  //         .toString()
  //         .replaceAll('[', '')
  //         .replaceAll(']', '')
  //         .toString();
  //   } else {
  //     debugPrint(respon.body);
  //     result = jsonDecode(respon.body)['message'];
  //   }
  //   return result;
  // } catch (e) {
  //   if (e is SocketException) {
  //     internet = false;
  //   }
  // }
}
}
