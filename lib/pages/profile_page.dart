import 'package:flutter/material.dart';
import 'package:keep_healthy/services/database_service.dart';
import '../models/user.dart';
import '../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final DatabaseService databaseService;
  late final CloudinaryService cloudinaryService;

  static const _bg = Color(0xFF0F1117);
  static const _purple = Color(0xFF6C63FF);
  static const _teal = Color(0xFF00D4AA);
  static const _pink = Color(0xFFFF7B9C);

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService();
    cloudinaryService = CloudinaryService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [_purple, _teal]),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      key: ValueKey(widget.user.imageUrl),
                      radius: 52,
                      backgroundImage: widget.user.imageUrl == null
                          ? const AssetImage("assets/images/default_user.jpg")
                          : NetworkImage(widget.user.imageUrl!) as ImageProvider,
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [_purple, _teal]),
                        border: Border.all(color: _bg, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Name ─────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    "${widget.user.name} ${widget.user.surName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "@${widget.user.username}",
                    style: const TextStyle(
                        color: _teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stat Cards ───────────────────────────────────
            Row(
              children: [
                _statCard(Icons.monitor_weight_rounded,
                    "${widget.user.weight.toStringAsFixed(1)} kg", "Weight", _purple),
                const SizedBox(width: 12),
                _statCard(Icons.bar_chart_rounded,
                    "${widget.user.usageCount}", "Progress", _teal),
              ],
            ),
            const SizedBox(height: 24),

            // ── Account Info ─────────────────────────────────
            Text("ACCOUNT INFO",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.email_rounded, "Email",
                      widget.user.email, _purple),
                  Divider(height: 1, color: Colors.white.withOpacity(0.06),
                      indent: 16, endIndent: 16),
                  _infoRow(Icons.person_rounded, "Full Name",
                      "${widget.user.name} ${widget.user.surName}", _teal),
                  Divider(height: 1, color: Colors.white.withOpacity(0.06),
                      indent: 16, endIndent: 16),
                  _infoRow(Icons.alternate_email_rounded, "Username",
                      widget.user.username, _pink),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Settings ─────────────────────────────────────
            Text("SETTINGS",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_a_photo_rounded,
                            color: _purple, size: 18),
                      ),
                      const SizedBox(width: 14),
                      const Text("Change Profile Picture",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (pickedFile == null) return;

    final String uID = auth.FirebaseAuth.instance.currentUser!.uid;
    final String? uploadUrl =
        await cloudinaryService.uploadProfilePicture(pickedFile.path);
    setState(() {
      widget.user.imageUrl = uploadUrl;
    });
    databaseService.updateProfileImageUrl(widget.user.imageUrl!, uID);
  }
}