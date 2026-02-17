import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../services/database_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

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
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text("Username: ${userAcc!.username}"),
        Text("Name: ${userAcc!.name} ${userAcc!.surName}"),

        ElevatedButton(
          onPressed: () {
            auth.FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login-page',
              (_) => false
            );
          },
          child: const Text('Logout'),
        )
      ],
    );
  }
}
