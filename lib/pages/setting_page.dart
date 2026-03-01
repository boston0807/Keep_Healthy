import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../models/user.dart' as app_user;
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart' ;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:keep_healthy/services/database_service.dart';

class SettingPage extends StatefulWidget {
  final app_user.User user ;
  const SettingPage({super.key, required this.user});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late CloudinaryService cloudinary;
  DatabaseService dataBase = DatabaseService();

  @override 
  void initState(){
    super.initState();
    cloudinary = CloudinaryService();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.user.imageUrl == null ?
        Image.asset("assets/iamge/default_user.jpg") :
        Image.network(widget.user.imageUrl!,
        errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/default_user.jpg"),),
        SizedBox(height: 30,),
        ElevatedButton(onPressed: () async{
          final ImagePicker imagePicker = ImagePicker();
          final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
          if (pickedFile == null){
            return;
          }
          else{
            final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
            final String? uploadUrl = await cloudinary.upload(pickedFile.path, uID);
            setState(() {
              widget.user.imageUrl = uploadUrl;
            });
            dataBase.updateProfileImageUrl(widget.user.imageUrl!, uID);
          }
        }, child: Text("Change Profile Picture"))
      ],
    );
  }
}