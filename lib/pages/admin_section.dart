import 'package:admin_panel/pages/staff_management_page.dart';
import 'package:flutter/material.dart';

class AdminSection extends StatelessWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.group, color: Colors.blueAccent),
        title: const Text(
          "Manage Staff",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          "Create and manage staff accounts",
          style: TextStyle(color: Colors.white70),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffManagementPage()),
          );
        },
      ),
    );
  }
}
