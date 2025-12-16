import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';
import '../../core/config.dart';

class StaffSettingsPage extends StatefulWidget {
  const StaffSettingsPage({super.key});

  @override
  State<StaffSettingsPage> createState() => _StaffSettingsPageState();
}

class _StaffSettingsPageState extends State<StaffSettingsPage> {
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
          AccountSection(),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final AppUser user;
  const ProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'No name',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
        onTap: () async {
          await AppConfig.supabase.auth.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        },
      ),
    );
  }
}
