import 'package:connect/services/auth_service.dart';
import 'package:connect/views/auth/sign_up_view.dart';
import 'package:connect/views/feeds/feed_view.dart';
import 'package:connect/views/widgets/snackBar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _isLoginSelected = true;
  bool _isVisible = false;
  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  // void toggleLogin() {
  //   setState(() {
  //     _isLoginSelected = !_isLoginSelected;
  //   });
  // }

  bool _isLoading = false;

  Future<void> authenticate() async {
    final valid = _formKey.currentState!.validate();
    if (valid) {
      String email = _emailController.text;
      String password = _passwordController.text;
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        setState(() {
          _isLoading = true;
        });
        await authService.login(email, password).then((value) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FeedView()),
          );
          snack(context, "Login Successful", Colors.green);
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        snack(context, "Incorrect email or password.", Colors.amber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.cyan, Colors.cyan, Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicContainer(
              width: mediaQuery.size.width * 0.9,
              height: mediaQuery.size.height * 0.52,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            _isLoginSelected ? 'Login' : "SignUp",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) {
                          if (v == null) {
                            return "Please Enter Your email";
                          } else if (!v.contains("@")) {
                            return "Please enter a valid mail id.";
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
                        controller: _passwordController,
                        obscureText: !_isVisible,
                        validator: (v) {
                          if (v == null || v == "") {
                            return "Please Enter Password";
                          } else if (v.length < 8) {
                            return _isLoginSelected
                                ? null
                                : "Please use atleast 8 character";
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
                          onPressed: () => authenticate(),
                          child: Text(
                            _isLoginSelected ? 'Login' : "Signup",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 60,
                      ),
                      RichText(
                        text: TextSpan(
                          text: _isLoginSelected
                              ? "Don't have an account? "
                              : "Already Have an Account? ",
                          style: const TextStyle(color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: _isLoginSelected ? 'SignUp' : "Login",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _isLoading
                                    ? () {}
                                    : () => Navigator.of(context)
                                        .pushNamed(SignupScreen.routeName),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
