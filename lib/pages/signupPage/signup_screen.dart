import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../functions/functions.dart';
import '../../modals/vehicle_type.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/vehicle_type_update.dart';
import '../loadingPage/loading.dart';
import '../login/get_started.dart';
import '../onTripPage/map_page.dart';
import '../vehicleInformations/vehicle_type.dart';
import 'email_verify_screen.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key, required this.serviceId}) : super(key: key);
  final String serviceId;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  File? imagefile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _driverLicenseController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();

  bool passwordVisible = false;
  bool _isLoading = false;
  bool passwordConfirmVisible = false;

  final _formKey = GlobalKey<FormState>();
  final _emailRegex = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');


  String? _selectedItem;
  List<Data> _dropdownItems = [];
  Data? _selectedVehicleType;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    passwordConfirmVisible = true;
  }

  Future<void> camera() async {
    final cameraFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (cameraFile == null) return;
    setState(() {
      imagefile = File(cameraFile.path);
    });
  }

  Future<void> galleryImage() async {
    final galleryFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (galleryFile == null) return;
    setState(() {
      imagefile = File(galleryFile.path);
    });
  }

  void showDialogbox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  galleryImage();
                },
                title: const Text("Select from Gallery"),
                leading: const Icon(Icons.photo_album_outlined),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  camera();
                },
                title: const Text("Take a Photo"),
                leading: const Icon(CupertinoIcons.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchVehicleTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      VechicalType vechicalType = await getvehicleType(widget.serviceId, _companyIdController.text);
      setState(() {
        _dropdownItems = vechicalType.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching vehicle types: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/36759121.png',
                        height: media.height * 0.20,
                      ),
                    ),
                    Text(
                      'Sign Up',
                      style: GoogleFonts.roboto(
                        fontSize: media.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: CupertinoButton(
                        onPressed: () => showDialogbox(),
                        child: const CircleAvatar(
                          child: Icon(
                            CupertinoIcons.person,
                            color: Color.fromARGB(255, 30, 31, 32),
                            size: 60,
                          ),
                          backgroundColor: Color.fromARGB(255, 202, 202, 202),
                          radius: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Name",
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Please Enter Name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Email",
                      ),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: passwordVisible,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        labelText: "Password",
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Please Enter Password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: passwordConfirmVisible,
                      controller: _passwordConfirmController,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(passwordConfirmVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              passwordConfirmVisible = !passwordConfirmVisible;
                            });
                          },
                        ),
                        labelText: "Confirm Password",
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Please Re-Enter Password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _mobileController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: "Phone Number",
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Please Enter the phone number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _driverLicenseController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.card_travel),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Driver License",
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Please Enter Driver License";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _companyIdController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.business),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Company Id",
                      ),
                      onChanged: (String value) {
                        // Fetch vehicle types when company ID changes
                        _fetchVehicleTypes();
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      Center(
                        child: Loading(),
                      ),
                    DropdownButtonFormField<Data>(
                      value: _selectedVehicleType,
                      hint: const Text("Select Vehicle Type"),
                      items: _dropdownItems.map((Data vehicleType) {
                        return DropdownMenuItem<Data>(
                          value: vehicleType,
                          child: Row(
                            children: [
                              vehicleType.icon != null && vehicleType.icon!.isNotEmpty
                                  ? Image.network(vehicleType.icon!, width: 40, height: 40, fit: BoxFit.cover)
                                  : Container(width: 40, height: 40, color: Colors.grey), // Placeholder
                              const SizedBox(width: 10),
                              Text(vehicleType.name ?? "Unknown"),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (Data? newValue) {
                        setState(() {
                          _selectedVehicleType = newValue;
                        });
                      },
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: media.height * 0.05),
                    Container(
                      width: media.width * 0.92,
                      alignment: Alignment.center,
                      child: Button(
                        onTap: () async {
                          String password = _passwordController.text;
                          String confirmPassword = _passwordConfirmController.text;
                          if (_formKey.currentState!.validate()) {
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password and confirm password do not match'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _isLoading = true; // Show loading indicator
                            });
                            var registrationResult = await registerDriver(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              phNumber: _mobileController.text,
                              confPassword: _passwordConfirmController.text,
                              driverLicence: _driverLicenseController.text,
                              companyId: _companyIdController.text,
                              serviceId: widget.serviceId,
                              myVehicleId: _selectedVehicleType!.id ?? "",
                            );
                            setState(() {
                              _isLoading = false; // Hide loading indicator
                            });
                            if (registrationResult == "true") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please verify your email'),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login_otp(email: _emailController.text),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(registrationResult.toString()),
                                ),
                              );
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                        text: languages[choosenLanguage]['text_signup'],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: Loading(),
            ),
        ],
      ),
    );
  }





  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address.";
    } else if (!_emailRegex.hasMatch(value)) {
      return "Please enter a valid email address.";
    }
    return null;
  }
}
