import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/login/reset_password.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailRegex = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Scaffold(
      body: Form(
        key: _formKey,
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
                languages[choosenLanguage]['text_forgotP'],
                style: GoogleFonts.roboto(
                    fontSize: media.width * twentysix,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              SizedBox(height: 30,),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Color(0xffF2F3F5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                  labelText: "Email",
                ),
                onSaved: (String? value) {},
                validator: validateEmail,
              ),
              SizedBox(height: 50,),
              Container(
                width: media.width * 1 - media.width * 0.08,
                alignment: Alignment.center,
                child: Button(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      _errorMessage =
                          validateEmail(_emailController.text);
                      forgotPassword(
                        email:_emailController.text,
                      );
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>  ResetPassword(
                        email:_emailController.text,
                      )));
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  text: languages[choosenLanguage]['text_resetPasswor'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Email is required";
    } else if (!_emailRegex.hasMatch(value)) {
      return "Invalid  email format";
    }
    return null;
  }
}
