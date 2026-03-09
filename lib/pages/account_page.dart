import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as app_user;
import '../providers/theme_provider.dart';
import '../config/theme_config.dart';
import '../services/database_service.dart';

class AccountPage extends StatefulWidget {
  final app_user.User user;
  const AccountPage({super.key, required this.user});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const _errorColor = Color(0xFFFF5C6A);
  static const _successColor = Color(0xFF3ECFA3);

  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _surNameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _firstNameController = TextEditingController(text: widget.user.name);
    _surNameController = TextEditingController(text: widget.user.surName);
    _emailController = TextEditingController(text: widget.user.email);
    _weightController = TextEditingController(text: widget.user.weight.toString());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _surNameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(AppTheme theme) async {

  final username = _usernameController.text.trim();
  final name = _firstNameController.text.trim();
  final surname = _surNameController.text.trim();
  final email = _emailController.text.trim();
  final weightStr = _weightController.text.trim();

  if (username.isEmpty || name.isEmpty || surname.isEmpty || email.isEmpty || weightStr.isEmpty) {
    _showSnackbar('Please fill in all fields', isError: true);
    return;
  }

  final weight = double.tryParse(weightStr);
  if (weight == null || weight <= 0) {
    _showSnackbar('Invalid weight value', isError: true);
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {

    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception("User not logged in");
    }

    final uid = firebaseUser.uid;

    final db = DatabaseService();

    await db.updateUserUsername(uid, username);
    await db.updateUserFirstName(uid, name);
    await db.updateUserSurName(uid, surname);
    await db.updateUserWeight(uid, weight);
    await db.updateUserEmail(uid, email);

    if (email != firebaseUser.email) {
      await firebaseUser.verifyBeforeUpdateEmail(email);
      _showSnackbar("Verification email sent");
    }

    if (!mounted) return;

    setState(() {
      _isEditing = false;
      _isSaving = false;
    });

    _showSnackbar("Account updated successfully");

  } catch (e) {

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }

    _showSnackbar("Failed to update account", isError: true);
  }
}

  void _showSnackbar(String message, {bool isError = false}) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? theme.colorScheme.error 
            : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;

      _usernameController.text = widget.user.username;
      _firstNameController.text = widget.user.name;
      _surNameController.text = widget.user.surName;
      _emailController.text = widget.user.email;
      _weightController.text = widget.user.weight.toString();
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
              ),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            child: const Text("Change"),
            onPressed: () async {

              final currentPass = currentPassController.text.trim();
              final newPass = newPassController.text.trim();
              final confirmPass = confirmPassController.text.trim();

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }

              try {

                final user = auth.FirebaseAuth.instance.currentUser!;

                final cred = auth.EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPass,
                );

                await user.reauthenticateWithCredential(cred);

                await user.updatePassword(newPass);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password changed successfully"),
                    ),
                  );
                }

              } catch (e) {

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                    ),
                  );
                }

              }
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit_rounded, size: 16, color: theme.accent),
              label: Text('Edit',
                  style: TextStyle(color: theme.accent, fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: _cancelEdit,
              child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'PERSONAL INFO', theme: theme),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _EditableRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Username',
                    controller: _usernameController,
                    isEditing: _isEditing,
                    theme: theme,
                  ),
                  _Divider(theme: theme),
                  _EditableRow(
                    icon: Icons.badge_outlined,
                    label: 'First Name',
                    controller: _firstNameController,
                    isEditing: _isEditing,
                    theme: theme,
                  ),
                  _Divider(theme: theme),
                  _EditableRow(
                    icon: Icons.badge_outlined,
                    label: 'Last Name',
                    controller: _surNameController,
                    isEditing: _isEditing,
                    theme: theme,
                  ),
                  _Divider(theme: theme),
                  _EditableRow(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight (kg)',
                    controller: _weightController,
                    isEditing: _isEditing,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _SectionLabel(label: 'ACCOUNT', theme: theme),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _EditableRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    controller: _emailController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    theme: theme,
                  ),
                  _Divider(theme: theme),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.lock_outline_rounded, color: theme.accent, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Password',
                                  style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                _passwordVisible ? '••••••••  (hidden)' : '••••••••',
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
                          onPressed: () =>
                              setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : () => _saveChanges(theme),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : 'Apply Changes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_reset_rounded, size: 18),
                label: const Text('Change Password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accent,
                  side: BorderSide(color: theme.accent.withOpacity(0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;
  final AppTheme theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: theme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}


class _Divider extends StatelessWidget {
  final AppTheme theme;
  const _Divider({required this.theme});

  @override
  Widget build(BuildContext context) => Divider(
      color: theme.textSecondary.withOpacity(0.15),
      height: 1,
      indent: 20,
      endIndent: 20);
}


class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final AppTheme theme;
  final TextInputType keyboardType;

  const _EditableRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.theme,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isEditing ? 10 : 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: theme.bg,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.accent, width: 1.5),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? '—' : controller.text,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}


class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final AppTheme theme;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.theme,
    this.isPassword = false,
    this.isVisible = true,
    this.onToggle,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13),
        filled: true,
        fillColor: theme.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.accent, width: 1.5),
        ),
        suffixIcon: isPassword && onToggle != null
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: theme.textSecondary,
                  size: 18,
                ),
                onPressed: onToggle,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}