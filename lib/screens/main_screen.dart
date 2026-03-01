import 'package:flutter/material.dart';
import 'package:keep_healthy/pages/setting_page.dart';
import '../pages/menu_page.dart';
import '../pages/camera_page.dart';
import '../pages/dash_board.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
class MainScreen extends StatefulWidget {
  final String nutrientImage;
  final int initializeIndex;
  const MainScreen({super.key, required this.initializeIndex , required this.nutrientImage});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  User? userAcc ; 
  late int indexBottomNav ;
  late String nutrientImagePath;
  late List widgetOption ;

  @override
  void initState() {
    super.initState();
    indexBottomNav = widget.initializeIndex;
    nutrientImagePath = widget.nutrientImage;

    final firebaseUser = auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      loadUser(firebaseUser.uid);
    } else {
      auth.FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          loadUser(user.uid);
        }
      });
    }
  }

  Future<void> loadUser(String uID) async{
    User user = await User.createUser(uID); 
    setState(() {
    userAcc = user;
    widgetOption = [MenuPage(user: userAcc!,), Text('Dashboard'), SizedBox(), SettingPage(user: userAcc!,), Text('Info')];
    });  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keep Healthy')),
      body: (userAcc == null) ? 
      const Center(
        child: CircularProgressIndicator()
        )
      :
      Center(
        child: nutrientImagePath.isEmpty ? widgetOption[indexBottomNav] : DashBoard(imagePath: nutrientImagePath,userWeight: userAcc!.weight,)
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: indexBottomNav,
      onTap: (value) {
        if (value == 2){
          _pushToCamera();
          return;
        } 

        setState(() {
          nutrientImagePath = "";
          indexBottomNav = value;
        });
      },
      backgroundColor: const Color(0xFF10297B),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      )
    ); 
  }

  void _pushToCamera() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage()));
  }
}