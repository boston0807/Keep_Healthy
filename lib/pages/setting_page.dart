import 'package:flutter/material.dart';
import 'package:keep_healthy/pages/account_page.dart';
import 'dart:async';
import '../models/user.dart' as app_user;
import '../services/cloudinary_service.dart' ;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:keep_healthy/services/database_service.dart';
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

List<Map<String, dynamic>> get _settingItems {
  final theme = context.read<ThemeProvider>().current;
  return [
    {'title': 'Account',        'icon': Icons.person,           'color': theme.textPrimary},
    {'title': 'Notifications',  'icon': Icons.notifications,    'color': theme.textPrimary},
    {'title': 'Theme',          'icon': Icons.palette_outlined, 'color': theme.textPrimary},
    {'title': 'Help & Support', 'icon': Icons.help,             'color': theme.textPrimary},
    {'title': 'Logout',         'icon': Icons.logout,           'color': Colors.red},
  ];
}

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
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
      backgroundColor: theme.bg,
        title: Text("Setting", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textPrimary),),
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
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Search for a setting...",
                  hintStyle: TextStyle(color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.bgSecondary,
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
            
            Text("General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textSecondary),),
            const SizedBox(height: 10),

            Expanded(
              child: _settingItems
                      .where((item) => (item['title'] as String)
                          .toLowerCase()
                          .contains(_searchQuery))
                      .isEmpty
                  ? Center(
                      child: Text("No results found",
                          style: TextStyle(color: theme.textSecondary, fontSize: 16)),
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
                                tileColor: theme.bg,
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
  final theme = context.read<ThemeProvider>().current;
  switch (title) {
    case 'Account':
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => AccountPage(user: widget.user)));
      break;
    case 'Notifications':
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor:  theme.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Enable Notifications",
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(
              "Allow Keep Healthy to send you health reminders and updates?",
              style: TextStyle(color: theme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: TextStyle(color: theme.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:  Text("Allow", style: TextStyle(color: theme.accent)),
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
        backgroundColor: theme.bg,
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
                 Text("Choose Theme",
                      style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...AppThemes.all.map((t) => ListTile(
                        leading: CircleAvatar(
                            backgroundColor: t.bg, radius: 14, child: Container(decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.accent,
                                width: 1.5,
                              ),
                            ))),
                        title: Text(t.name,
                            style: TextStyle(color: theme.textPrimary)),
                        trailing: provider.current.id == t.id
                            ?  Icon(Icons.check_rounded,
                                color: theme.accent)
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
          backgroundColor: theme.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Help & Support",
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact Support", style: TextStyle(color: theme.textSecondary)),
              SizedBox(height: 12),
              Row(children: [
                Icon(Icons.email_rounded, color: Color(0xFF4F8EF7), size: 18),
                SizedBox(width: 8),
                Text("bostonkc55h4@gmail.com", style: TextStyle(color: theme.textPrimary)),
              ]),
              SizedBox(height: 8),
              Row(children: [
                Icon(Icons.email_rounded, color: Color(0xFF4F8EF7), size: 18),
                SizedBox(width: 8),
                Text("atchira.p@ku.th", style: TextStyle(color: theme.textPrimary)),
              ]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: theme.textSecondary)),
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