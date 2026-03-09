import 'package:flutter/material.dart';
import 'package:keep_healthy/firebase_options.dart';
import 'package:keep_healthy/pages/register_page.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/menu_page.dart';
import 'pages/dashboard_page.dart';
import '../screens/main_screen.dart';
import 'pages/food_detail_page.dart';
import 'models/food_nutrient.dart';
import 'pages/account_page.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

  void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
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
          '/menu-page':(context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;  

            return MenuPage(user: args?['user']);
          },
          '/dashboard-page':(context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

            return DashBoard(imagePath: args?['imagePath'], userWeight: args?['weight'], user: args?['user'], uID: args?['uID'],);
          },
          '/setting-page':(context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          return MenuPage(user: args?['user']);
        },
        '/food-detail-page': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

            return FoodDetailPage(
              food: args?['food'] as FoodNutrient,
              weight: args?['weight'],
            );
        },
        'account-page':(context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

            return AccountPage(user: args?['user']);
        },
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