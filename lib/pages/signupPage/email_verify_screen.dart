import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../onTripPage/map_page.dart';

class OtpScreen extends StatefulWidget {
  OtpScreen({key,required this.email});
  String? email;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Scaffold(
      body: Stack(
        children:[ Form(
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
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      languages[choosenLanguage]['email_verify'] ?? "",
                      style: GoogleFonts.roboto(
                          fontSize: media.width * twentysix,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffF2F3F5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      labelText: "Otp",
                    ),
                    onSaved: (String? value) {},
                    validator:validateOtp,),
                  const SizedBox(height: 50,),
                  Container(
                    width: media.width * 1 - media.width * 0.08,
                    alignment: Alignment.center,
                    child: Button(
                      onTap: () async {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) =>  Maps()),
                        // );
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          String errorMessage ='';
                          if (errorMessage.isEmpty) {
                            // OTP is valid, attempt to verify
                            bool isOtpValid = await emailVerify(
                              email: widget.email,
                              otp: _otpController.text,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            if (isOtpValid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  Maps()),
                              );
                            } else {
                              // Registration failed, show error message in a Snackbar
                              setState(() {
                                _otpController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration:Duration(seconds: 20) ,
                                      content: Text('${emailVerify.toString()}')),
                                );
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
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: ()async {
                            String errorMessage ='';
                            if (errorMessage.isEmpty) {
                              // OTP is valid, attempt to verify
                              bool isOtpValid = await resendOtpRegister(
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
          if (_isLoading)
            Center(
              child: Loading(),
            ),
     ] ),
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