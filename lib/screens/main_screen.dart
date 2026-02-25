import 'package:flutter/material.dart';
import '../pages/menu_page.dart';
import '../pages/camera_page.dart';
import '../pages/dash_board.dart';

class MainScreen extends StatefulWidget {
  final String nutrientImage;
  final int initializeIndex;
  const MainScreen({super.key, required this.initializeIndex , required this.nutrientImage});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int indexBottomNav ;
  late String nutrientImagePath;
  late List widgetOption ;

  @override 
  void initState(){
    super.initState();
    indexBottomNav = widget.initializeIndex;
    nutrientImagePath = widget.nutrientImage ;
    widgetOption = [MenuPage(), Text('Dashboard'), SizedBox(), Text('Setting'), Text('Info')];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keep Healthy')),
      body: Center(
        child: nutrientImagePath.isEmpty ? widgetOption[indexBottomNav] : DashBoard(imagePath: nutrientImagePath,)
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