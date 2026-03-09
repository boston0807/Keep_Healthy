import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import '../models/user.dart' as app_user;
import '../providers/theme_provider.dart';

class AccountPage extends StatefulWidget {
  final app_user.User user;
  const AccountPage({super.key, required this.user});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const _errorColor = Color(0xFFFF5C6A);
  static const _successColor = Color(0xFF3ECFA3);

  bool _passwordVisible = false;
  
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = widget.user.email;
  }

  // Change Password Dialog
  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;
    bool isLoading = false;
    String? errorMessage;

    final theme = context.watch<ThemeProvider>().current;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> handleChangePassword() async {
              final current = currentCtrl.text.trim();
              final newPass = newCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();

              // Validation
              if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                setDialogState(() => errorMessage = "Please fill in all fields");
                return;
              }
              if (newPass.length < 6) {
                setDialogState(() =>
                    errorMessage = "New password must be at least 6 characters");
                return;
              }
              if (newPass != confirm) {
                setDialogState(
                    () => errorMessage = "New passwords do not match");
                return;
              }

              setDialogState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final user = auth.FirebaseAuth.instance.currentUser!;
                final credential = auth.EmailAuthProvider.credential(
                  email: user.email!,
                  password: current,
                );

                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPass);

                if (!mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text("Password changed successfully"),
                      ],
                    ),
                    backgroundColor: _successColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } on auth.FirebaseAuthException catch (e) {
                String msg = "Something went wrong";
                if (e.code == 'wrong-password') {
                  msg = "Current password is incorrect";
                } else if (e.code == 'weak-password') {
                  msg = "New password is too weak";
                } else if (e.code == 'requires-recent-login') {
                  msg = "Please log in again before changing password";
                }
                setDialogState(() {
                  isLoading = false;
                  errorMessage = msg;
                });
              }
            }

            return AlertDialog(
              backgroundColor: theme.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: theme.accent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "Change Password",
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error message
                    if (errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _errorColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: _errorColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                    color: _errorColor, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Current Password
                    _DialogTextField(
                      controller: currentCtrl,
                      label: "Current Password",
                      isVisible: showCurrent,
                      onToggle: () =>
                          setDialogState(() => showCurrent = !showCurrent),
                    ),
                    const SizedBox(height: 12),

                    // New Password
                    _DialogTextField(
                      controller: newCtrl,
                      label: "New Password",
                      isVisible: showNew,
                      onToggle: () =>
                          setDialogState(() => showNew = !showNew),
                    ),
                    const SizedBox(height: 12),

                    // Confirm New Password
                    _DialogTextField(
                      controller: confirmCtrl,
                      label: "Confirm New Password",
                      isVisible: showConfirm,
                      onToggle: () =>
                          setDialogState(() => showConfirm = !showConfirm),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(color: theme.textSecondary)),
                ),
                FilledButton(
                  onPressed: isLoading ? null : handleChangePassword,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Confirm",
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).current;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Account",
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            Text(
              "ACCOUNT INFO",
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            // Info Card
            Container(
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Email row
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: "Email",
                    value: _email,
                  ),

                  Divider(
                      color: theme.textSecondary.withOpacity(0.15),
                      height: 1,
                      indent: 20,
                      endIndent: 20),

                  // Password row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.lock_outline_rounded,
                              color: theme.accent, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Password",
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _passwordVisible
                                    ? "••••••••  (hidden)"
                                    : "••••••••",
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: theme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangePasswordDialog,
                icon: const Icon(Icons.lock_reset_rounded, size: 18),
                label: const Text("Change Password"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accent,
                  side: BorderSide(color: theme.accent.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const _accent = Color(0xFF4F8EF7);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog TextField Widget

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onToggle;

  static const _card = Color(0xFF0F1117);
  static const _accent = Color(0xFF4F8EF7);
  static const _textPrimary = Color(0xFFEEF0F8);
  static const _textSecondary = Color(0xFF7B82A3);

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        filled: true,
        fillColor: _card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: _textSecondary,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}