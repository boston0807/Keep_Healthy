import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../models/user.dart' as app_user;
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart' ;
import 'package:firebase_auth/firebase_auth.dart' as auth;

class SettingPage extends StatefulWidget {
  final app_user.User user ;
  const SettingPage({super.key, required this.user});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? imagePath;

  @override 
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        imagePath == null
        ? Image.asset("assets/images/default_user.jpg", width: 200)
        : Image.file(File(imagePath!), width: 200),
        SizedBox(height: 30,),
        ElevatedButton(onPressed: () async{
          final ImagePicker imagePicker = ImagePicker();
          final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
          if (pickedFile == null) return;
          setState(() {
            var cloudinary = CloudinaryService();
            cloudinary.upload(pickedFile.path, auth.FirebaseAuth.instance.currentUser!.uid);
          });
        }, child: Text("Change Profile Picture"))
      ],
    );
  }
}