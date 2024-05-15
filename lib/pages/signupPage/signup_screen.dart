import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../login/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  bool passwordVisible = false;
  bool passwordConfirmVisible = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  @override
  void initState() {
    passwordVisible = true;
    passwordConfirmVisible = true;
    super.initState();
  }
  final _emailRegex = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key:_formKey ,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/36759121.png',
                    height:
                    MediaQuery.of(context).size.height * 0.25,
                  ),
                ),

                //SizedBox(height: media.height * 0.195),
                Text(
                  languages[choosenLanguage]["text_signup"],
                  style: GoogleFonts.roboto(
                      fontSize: media.width * twentysix,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                SizedBox(
                  height: 60,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    labelText: "Name",
                  ),
                  onSaved: (String? value) {},
                  validator:  (String? value) {
                    if (value!.isEmpty) {
                      return "Please Enter Name";
                    } else {
                      return null;
                    }
                  },),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                TextFormField(
                  obscureText: passwordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
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
                    labelText: "Password",
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "Please Re-Enter New Password";
                    } else {
                      return null;
                    }
                  },),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: passwordConfirmVisible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                        icon: Icon(passwordConfirmVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                                () {
                                  passwordConfirmVisible = !passwordConfirmVisible;
                            },
                          );
                        }),
                    labelText: "Confirm Password",
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "Please Re-Enter New Password";
                    } else {
                      return null;
                    }
                  },),

                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  controller: _mobileController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: "Phone Number",
                    filled: true,
                    fillColor: Color(0xffF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "Please Enter the phone number";
                    } else {
                      return null;
                    }
                  },),
                SizedBox(height: media.height * 0.05),
                Container(
                  width: media.width * 1 - media.width * 0.08,
                  alignment: Alignment.center,
                  child: Button(
                    onTap: () async {
                      String password = _passwordController.text;
                      String confirmPassword = _passwordConfirmController.text;
                      if (_formKey.currentState!.validate()) {
                        _errorMessage =
                            validateEmail(_emailController.text);
                        _errorMessage = validatePassword(
                            _passwordController.text);
                      }
                      registerUser(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phNumber: _mobileController.text,
                        confPassword: _passwordConfirmController.text,
                      );
                      Navigator.pop(context);
                      if(password != confirmPassword){
                        setState(() {
                          SnackBar(content:Text('Password and confirm password do not match') );
                        });
                        return;
                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    text: languages[choosenLanguage]['text_signup'],
                  ),
                ),
              ],
            ),
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
  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    // else if (!_passwordRegex.hasMatch(value)) {
    //   return "Invalid password format";
    // }
    return null;
  }
}
