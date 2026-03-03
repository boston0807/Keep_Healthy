import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../services/database_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrient Dashboard"),
        actions: [

      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF10297B),
              child: Text(
                userAcc!.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 