import 'package:connect/firebase_options.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/views/auth/login_view.dart';
import 'package:connect/views/auth/login_view.dart';
import 'package:connect/views/auth/sign_up_view.dart';
import 'package:connect/views/feeds/feed_view.dart';
import 'package:connect/views/home/homescreen_view.dart';
import 'package:connect/views/post/add_post.dart';
import 'package:connect/views/profile/edit_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        title: 'Social Media App',
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            return authService.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignupScreen.routeName: (_) => const SignupScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          PostUploadPage.routeName: (_) => const PostUploadPage(),
          ProfileEditPage.routeName: (_) => const ProfileEditPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
