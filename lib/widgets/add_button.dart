import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade700,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }
}
