import 'package:admin_panel/models/app_user.dart';
import 'package:flutter/material.dart';

class StaffTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const StaffTile({
    super.key,
    required this.user,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';

    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.redAccent,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user.fullName ?? user.email,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          user.email,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isActive ? Icons.block : Icons.check_circle,
                color: isActive ? Colors.orange : Colors.green,
              ),
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
