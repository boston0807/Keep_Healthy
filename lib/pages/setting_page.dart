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
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     widget.user.imageUrl == null ?
    //     Image.asset("assets/iamge/default_user.jpg") :
    //     Image.network(widget.user.imageUrl!,
    //     errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/default_user.jpg"),),
    //     SizedBox(height: 30,),
    //     ElevatedButton(onPressed: () async{
    //       final ImagePicker imagePicker = ImagePicker();
    //       final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
    //       if (pickedFile == null){
    //         return;
    //       }
    //       else{
    //         final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
    //         final String? uploadUrl = await cloudinary.upload(pickedFile.path, uID);
    //         setState(() {
    //           widget.user.imageUrl = uploadUrl;
    //         });
    //         dataBase.updateProfileImageUrl(widget.user.imageUrl!, uID);
    //       }
    //     }, child: Text("Change Profile Picture"))
    //   ],
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20 , vertical: 10),
        child: Column(
          children: [

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search for a setting...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Account"),
                    onTap: () {
                      // Handle Account tap
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text("Notifications"),
                    onTap: () {
                      // Handle notifications tap
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Privacy"),
                    onTap: () {
                      // Handle privacy tap
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("Help & Support"),
                    onTap: () {
                      // Handle help & support tap
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout", style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await auth.FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/login-page', (_) => false);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}