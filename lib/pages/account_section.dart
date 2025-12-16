import 'package:admin_panel/core/config.dart';
import 'package:flutter/material.dart';

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
