import 'package:flutter/material.dart';
import 'package:keep_healthy/firebase_options.dart';
import 'package:keep_healthy/register_page.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_page.dart';

void main() async{
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
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 16, 41, 123))
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login-page' : '/menu-page',
      routes: {
        '/menu-page':(context) => MenuPage(),
        '/login-page':(context) => LoginPage(),
        '/register-page':(context) => RegisterPage(),
      }, 
    );
  }
}