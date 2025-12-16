import 'package:admin_panel/models/app_user.dart';
import 'package:flutter/material.dart';

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
                    color: Colors.blueAccent,
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
