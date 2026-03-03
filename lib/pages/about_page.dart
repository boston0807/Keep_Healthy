import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../services/database_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  User? userAcc;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

    final uid = auth.FirebaseAuth.instance.currentUser!.uid;

    User user = await User.createUser(uid);

    setState(() {
      userAcc = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(),
        );
    }

    return Column(
      children: [

        SizedBox(height: 40),

        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
            "assets/images/keep_healthy(nobg).png",
          ),
        ),

        SizedBox(height: 20),

        Text(
          "Keep Healthy",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text("Version 1.0.0"),

        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Keep Healthy helps you track nutrition and reach your goals.",
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 20),

        Text("Developed by BOSS and X"),
      ],
    );
  }
}