import 'package:flutter/material.dart';
import 'package:keep_healthy/pages/account_page.dart';
import 'package:keep_healthy/pages/user_profile_edit.dart';
import 'dart:io';
import 'dart:async';
import '../models/user.dart' as app_user;
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart' ;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:keep_healthy/providers/database_service.dart';
import 'dart:async';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme_config.dart';

class SettingPage extends StatefulWidget {
  final app_user.User user ;
  const SettingPage({super.key, required this.user});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationGranted = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late final List<Map<String, dynamic>> _settingItems = [
    {'title': 'Account',        'icon': Icons.person,           'color': Colors.white},
    {'title': 'Notifications',  'icon': Icons.notifications,    'color': Colors.white},
    {'title': 'Theme',          'icon': Icons.palette_outlined, 'color': Colors.white}, // ← เพิ่มตรงนี้
    {'title': 'Help & Support', 'icon': Icons.help,             'color': Colors.white},
    {'title': 'Logout',         'icon': Icons.logout,           'color': Colors.red},
  ];

  static const _bg = Color(0xFF0F1117);

  late CloudinaryService cloudinary;
  DatabaseService dataBase = DatabaseService();

  @override 
  void initState(){
    super.initState();
    cloudinary = CloudinaryService();
    _checkNotificationStatus();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  

  Future<void> _checkNotificationStatus() async {
  final status = await _notificationService.isPermissionGranted();
  setState(() => _isNotificationGranted = status);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
      backgroundColor: _bg,
        title: const Text("Setting", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20 , vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.only(top: 5),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search for a setting...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 30,),
            
            Text("General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
            const SizedBox(height: 10),

            Expanded(
              child: _settingItems
                      .where((item) => (item['title'] as String)
                          .toLowerCase()
                          .contains(_searchQuery))
                      .isEmpty
                  ? const Center(
                      child: Text("No results found",
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView(
                      children: _settingItems
                          .where((item) => (item['title'] as String)
                              .toLowerCase()
                              .contains(_searchQuery))
                          .map((item) => ListTile(
                                leading: Icon(item['icon'] as IconData,
                                    color: item['color'] as Color),
                                title: Text(item['title'] as String,
                                    style: TextStyle(color: item['color'] as Color)),
                                onTap: () => _handleTap(item['title'] as String),
                                tileColor: _bg,
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(String title) {
  switch (title) {
    case 'Account':
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => AccountPage(user: widget.user)));
      break;
    case 'Notifications':
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Enable Notifications",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
              "Allow Keep Healthy to send you health reminders and updates?",
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Allow", style: TextStyle(color: Color(0xFF4F8EF7))),
            ),
          ],
        ),
      ).then((confirm) async {
        if (confirm == true) {
          await _notificationService.requestNotificationPermission();
          await _checkNotificationStatus();
        }
      });
      break;
    case 'Theme':
      final themeProvider = context.read<ThemeProvider>();
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1F35),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Choose Theme",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...AppThemes.all.map((t) => ListTile(
                        leading: CircleAvatar(
                            backgroundColor: t.accent, radius: 14),
                        title: Text(t.name,
                            style: const TextStyle(color: Colors.white)),
                        trailing: provider.current.id == t.id
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white)
                            : null,
                        onTap: () {
                          provider.setTheme(t);
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      );
      break;
    case 'Help & Support':
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Help & Support",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact Support", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 12),
              Row(children: [
                Icon(Icons.email_rounded, color: Color(0xFF4F8EF7), size: 18),
                SizedBox(width: 8),
                Text("bostonkc55h4@gmail.com", style: TextStyle(color: Colors.white)),
              ]),
              SizedBox(height: 8),
              Row(children: [
                Icon(Icons.email_rounded, color: Color(0xFF4F8EF7), size: 18),
                SizedBox(width: 8),
                Text("atchira.p@ku.th", style: TextStyle(color: Colors.white)),
              ]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
      break;
    case 'Logout':
      auth.FirebaseAuth.instance.signOut().then((_) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login-page', (_) => false);
      });
      break;
  }
}
}