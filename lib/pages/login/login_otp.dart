import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../onTripPage/map_page.dart';

class Login_otp extends StatefulWidget {
  Login_otp({key,required this.email});
  String? email;
  @override
  State<Login_otp> createState() => _Login_otpState();
}

class _Login_otpState extends State<Login_otp> {
  TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left:25,right: 25,top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/email.png',
                    height:
                    MediaQuery.of(context).size.height * 0.20,
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    languages[choosenLanguage]['email_verify'],
                    style: GoogleFonts.roboto(
                        fontSize: media.width * twentysix,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    labelText: "Otp",
                  ),
                  onSaved: (String? value) {},
                  validator:validateOtp,),
                SizedBox(height: 50,),
                Container(
                  width: media.width * 1 - media.width * 0.08,
                  alignment: Alignment.center,
                  child: Button(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        String errorMessage ='';
                        if (errorMessage.isEmpty) {
                          // OTP is valid, attempt to verify
                          bool isOtpValid = await loginemailVerify(
                            email: widget.email,
                            otp: _otpController.text,
                          );
                          if (isOtpValid) {
                            // Navigate to next screen if OTP is valid
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Maps()),
                            );
                          } else {
                            // Display error message if OTP is invalid
                            setState(() {
                              _errorMessage = languages[choosenLanguage]['text_invalid_otp'];
                            });
                          }
                        } else {
                          // Display error message if OTP is not in correct format
                          setState(() {
                            _errorMessage = errorMessage;
                          });
                        }
                      }
                      // Unfocus keyboard
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    text: languages[choosenLanguage]['text_submit'],
                  ),

                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: ()async {
                          String errorMessage ='';
                          if (errorMessage.isEmpty) {
                            // OTP is valid, attempt to verify
                            bool isOtpValid = await resendOtpLogin(
                              email: widget.email,
                            );

                          } else {
                            // Display error message if OTP is not in correct format
                            setState(() {
                              _errorMessage = errorMessage;
                            });
                          }
                          // Unfocus keyboard
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Text("Resend Otp")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "otp is required";
    }
    return null;
  }
  String? validateOtp(String? value) {
    if (value!.isEmpty) {
      return "Otp is required";
    }
    return null;
  }
}