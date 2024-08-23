import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/vehicle_type_update.dart';
import '../onTripPage/map_page.dart';

class Login_otp extends StatefulWidget {
  Login_otp({key, required this.email,  });
  String? email;

  @override
  State<Login_otp> createState() => _Login_otpState();
}

class _Login_otpState extends State<Login_otp> {
  TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showLoader() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoader() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      _showLoader();
      String errorMessage = '';
      if (errorMessage.isEmpty) {
        bool isOtpValid = await emailVerify(
          email: widget.email,
          otp: _otpController.text,
        );
        _hideLoader();
        if (isOtpValid) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Maps()),
          );
        } else {
          setState(() {
            _otpController.clear();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 30),
              content: Text(
                  'Your account is pending approval. Please wait for our team to review and approve your account.'),
            ));
          });
        }
      } else {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _resendOtp() async {
    _showLoader();
    String errorMessage = '';
    if (errorMessage.isEmpty) {
      bool isOtpSent = await resendOtpRegister(
        email: widget.email,
      );
      _hideLoader();
      if (isOtpSent) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP has been resent successfully.'),
        ));
      }
    } else {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
    FocusManager.instance.primaryFocus?.unfocus();
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
                        languages[choosenLanguage]['email_verify'] ?? '',
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twentysix,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                      validator: validateOtp,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      width: media.width * 1 - media.width * 0.08,
                      alignment: Alignment.center,
                      child: Button(
                        onTap: _verifyOtp,
                        text: languages[choosenLanguage]['text_submit'],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: _resendOtp, child: const Text("Resend Otp")),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Loading(),
            ),
        ],
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
