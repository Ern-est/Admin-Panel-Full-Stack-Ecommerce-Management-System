import 'package:admin_panel/models/app_user.dart';
import 'package:admin_panel/pages/account_section.dart';
import 'package:admin_panel/pages/admin_section.dart';
import 'package:admin_panel/pages/profile_section.dart';
import 'package:admin_panel/services/user_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppUser? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final u = await UserService.getCurrentUser();
    if (mounted) {
      setState(() {
        user = u;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(
        child: Text("User not found", style: TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSection(user: user!),
          const SizedBox(height: 32),
          const AccountSection(),
          const SizedBox(height: 32),
          if (user!.role == 'admin') const AdminSection(),
        ],
      ),
    );
  }
}
