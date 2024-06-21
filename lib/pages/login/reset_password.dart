import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';

class ResetPassword extends StatefulWidget {
   ResetPassword({key,required this.email});
String? email;
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool passwordVisible = false;
  bool confirmPVisible = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left:25,right: 25,top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/36759121.png',
                    height:
                    MediaQuery.of(context).size.height * 0.30,
                  ),
                ),
                Text(
                  languages[choosenLanguage]['text_resetPasswor'],
                  style: GoogleFonts.roboto(
                      fontSize: media.width * twentysix,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                                () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        }),
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    labelText: "Password",
                  ),
                  onSaved: (String? value) {},
                  validator: validatePassword,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPassword,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(confirmPVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                                () {
                                  confirmPVisible = !confirmPVisible;
                            },
                          );
                        }),
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    labelText: "Confirm Password",
                  ),
                  onSaved: (String? value) {},
                  validator: validatePassword,
                ),
                SizedBox(height: 20),
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
                        _errorMessage =
                            validatePassword(_passwordController.text);
                        _errorMessage = validateOtp(_otpController.text);
                        if (_errorMessage == null) {
                          var resetResult = await  resetPassword(
                            email:widget.email,
                            password: _passwordController.text,
                            confirmPassword: _confirmPassword.text,
                            otp: _otpController.text,
                          );
                          if (resetResult == true) {
                            // Navigate to new screen if login was successful
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Login())
                            );
                          } else {
                            // Show a snackbar with error if login failed
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Try another password'))
                            );
                          }
                        }

                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    text: languages[choosenLanguage]['text_submit'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    return null;
  }
  String? validateOtp(String? value) {
    if (value!.isEmpty) {
      return "OTP is required";
    }
    return null;
  }
}
