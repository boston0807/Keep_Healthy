import 'package:flutter/material.dart';
import '../pages/menu_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int indexBottomNav = 0;
  List widgetOption = const [MenuPage(), Text('Dashboard'), Text('Camera'), Text('Setting'), Text('Info')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keep Healthy')),
      body: Center(
        child: widgetOption[indexBottomNav],
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
      onTap: (value) => setState(() => indexBottomNav = value),
      backgroundColor: const Color(0xFF10297B),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      ),
    );
  }
}