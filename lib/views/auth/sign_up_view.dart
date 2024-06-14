import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:connect/services/auth_service.dart';
import 'package:connect/views/feeds/feed_view.dart';
import 'package:connect/views/widgets/snackBar.dart';
import 'package:glassmorphism/glassmorphism.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const routeName = "/signup";

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVisible = false;
  bool _isUserNameAvail = true;
  File? _image;

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool _isLoading = false;
  Future<void> checkUsernameExists() async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('userNames');

      QuerySnapshot result = await users
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          _isUserNameAvail = true;
        });
      } else {
        setState(() {
          _isUserNameAvail = false;
        });
      }
    } catch (e) {
      print('Error checking username: $e');
      setState(() {
        _isUserNameAvail = false;
      });
    }
  }

  Future<void> signup() async {
    final valid = _formKey.currentState!.validate();
    if (valid) {
      print("True");
      String email = _emailController.text;

      String password = _passwordController.text;
      String username = _usernameController.text;
      String bio = _bioController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        snack(context, "Passwords do not match", Colors.amber);
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);

      try {
        setState(() {
          _isLoading = true;
        });
        await databaseService
            .signup(email, password, username, bio, _image)
            .then(
          (value) {
            setState(() {
              _isLoading = false;
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FeedView()),
            );

            snack(context, "Signup Successful", Colors.green);
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        snack(context, e.toString(), Colors.amber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          "Signup",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.cyan, Colors.blue, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 50,
                              )
                            : null,
                      ),
                    ),
                    // const SizedBox(height: 20),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Please Enter Your email";
                        } else if (!v.contains("@")) {
                          return "Please enter a valid email id.";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        errorStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      validator: (v) {
                        if (v == null || v == "") {
                          return "Please Enter Your Username";
                        }
                        return null;
                      },
                      onChanged: (_) {
                        checkUsernameExists();
                      },
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        errorText:
                            _isUserNameAvail ? null : "Username not available.",
                        errorStyle: TextStyle(
                            color:
                                _isUserNameAvail ? Colors.black : Colors.white,
                            fontWeight: !_isUserNameAvail
                                ? FontWeight.bold
                                : FontWeight.w400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Please Enter Your Bio";
                        }
                        return null;
                      },
                      maxLines: 3,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Bio',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        errorStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Please Enter Password";
                        } else if (v.length < 8) {
                          return "Please use at least 8 characters";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isVisible,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Please Confirm Password";
                        } else if (v != _passwordController.text) {
                          return "Passwords do not match";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () => toggleVisibility(),
                          icon: Icon(
                            _isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () => signup(),
                        child: Text(
                          "Signup",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
