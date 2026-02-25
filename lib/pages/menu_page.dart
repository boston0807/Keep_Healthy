import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MenuPage extends StatefulWidget {
  final User user; 
  const MenuPage({super.key, required this.user});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text("Username: ${widget.user.username}"),
        Text("Name: ${widget.user.name} ${widget.user .surName}"),

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
        ),
        ElevatedButton(onPressed: processData, child: Text("Choose Food Picture")),
      ],
    );
  }

  Future<void> processData() async{
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80,maxWidth: 1024);
    if (pickedFile == null) return;
    Navigator.pushNamedAndRemoveUntil(context, '/main-screen', (_) => false, arguments: {'nutrientImage': pickedFile.path, 'initializeIndex': 0});
  }
}
