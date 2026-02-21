import 'package:flutter/material.dart';
import 'package:keep_healthy/firebase_options.dart';
import 'package:keep_healthy/pages/register_page.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/menu_page.dart';
import 'screens/main_screen.dart';

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
        colorScheme: .fromSeed(seedColor: const Color(0xFF10297B))
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login-page' : '/main-screen',
      routes: {
        '/menu-page':(context) => MenuPage(),
        '/login-page':(context) => LoginPage(),
        '/register-page':(context) => RegisterPage(),
        '/main-screen':(context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          return MainScreen(
            nutrientImage: args?['nutrientImage'] ?? "",
            initializeIndex: args?['initializeIndex']?? 0,
          );
        },
      }, 
    );
  }
}