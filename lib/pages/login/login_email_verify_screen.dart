import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../onTripPage/map_page.dart';
import '../vehicleInformations/vehicle_type.dart';

class LoginOtpScreen extends StatefulWidget {
  LoginOtpScreen({key, required this.email});
  String? email;

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false; // Track loading state
  final _formKey = GlobalKey<FormState>();

  // Function to handle API call and set loading state
  Future<void> _handleAPICall() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating API call with a delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/email.png',
                        height: MediaQuery.of(context).size.height * 0.20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        languages[choosenLanguage]['email_verify'] ?? "",
                        style: GoogleFonts.roboto(
                          fontSize: media.width * twentysix,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
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
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Otp",
                      ),
                      onSaved: (String? value) {},
                      validator: validateOtp,
                    ),
                    const SizedBox(height: 50,),
                    Container(
                      width: media.width * 1 - media.width * 0.08,
                      alignment: Alignment.center,
                      child: Button(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            // Navigate only if API call is successful
                            bool isOtpValid = await loginemailVerify(
                              email: widget.email,
                              otp: _otpController.text,
                            );

                            setState(() {
                              _isLoading = false;
                            });

                            if (isOtpValid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Maps()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text('Otp invalid.'),
                                ),
                              );
                            }
                          }
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
                          onTap: () async {
                            // Your resend OTP logic here
                          },
                          child: Text("Resend Otp"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display loader if API call is in progress
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Loading(),
              ),
            ),
        ],
      ),
    );
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Otp is required";
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
