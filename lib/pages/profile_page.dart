import 'package:flutter/material.dart';
import 'package:keep_healthy/services/database_service.dart';
import '../models/user.dart';
import '../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfilePage extends StatefulWidget {
  final User user ;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final DatabaseService databaseService;
  late final CloudinaryService cloudinaryService;

  @override
  void initState(){
    super.initState();
    databaseService = DatabaseService();
    cloudinaryService = CloudinaryService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.username}'s Profile",style: TextStyle(
          fontSize: 30,   
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
      ),
      body: Padding(padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: ValueKey(widget.user.imageUrl),
                padding: EdgeInsets.all(5),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: 
                    widget.user.imageUrl == null ? 
                    const AssetImage("assets/images/default_user.jpg")  : NetworkImage(widget.user.imageUrl!,),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black38, offset: Offset(1, 4), blurRadius: 5)]
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text("${widget.user.name}    ${widget.user.surName}", style: TextStyle(fontSize: 30, shadows: [Shadow(color: const Color.fromARGB(255, 89, 89, 89), offset: Offset(0, 3), blurRadius: 1)], fontWeight: FontWeight.bold),),
              SizedBox(
                height: 30,
              ),
              Text("Weight: ${widget.user.weight.toStringAsFixed(1)}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, shadows: [Shadow(color: const Color.fromARGB(255, 89, 89, 89), offset: Offset(0, 3), blurRadius: 1)],)),
              SizedBox(
                height: 30,
              ),
              Text("User Email: ${widget.user.email}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: const Color.fromARGB(255, 89, 89, 89), offset: Offset(0, 3), blurRadius: 1)],)),
              SizedBox(
                height: 30,
              ),
              Text("Progress Count: ${widget.user.usageCount}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, shadows: [Shadow(color: const Color.fromARGB(255, 89, 89, 89), offset: Offset(0, 3), blurRadius: 1)],)),
              SizedBox(
                height: 30,
              ),
              Padding(padding: EdgeInsets.all(10),
              child: SizedBox(
                child:  ElevatedButton(onPressed: () async{
                  final ImagePicker imagePicker = ImagePicker();
                  final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
                  if (pickedFile == null){
                    return;
                  }
                  else{
                    final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
                    final String? uploadUrl = await cloudinaryService.uploadProfilePicture(pickedFile.path);
                    setState(() {
                      widget.user.imageUrl = uploadUrl;
                    });
                    databaseService.updateProfileImageUrl(widget.user.imageUrl!, uID);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.black
                ),
                child: Text("Change Profile Picture", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: const Color.fromARGB(255, 129, 129, 129), offset: Offset(0, 1), blurRadius: 1)],)),
                  ),
                )       
              ),       
            ],
          ),
        )
      ),
    );
  }
}

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