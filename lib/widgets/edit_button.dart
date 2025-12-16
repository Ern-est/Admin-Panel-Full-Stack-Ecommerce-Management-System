import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const EditButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blueAccent),
      tooltip: "Edit",
      onPressed: onTap,
    );
  }
}
