import 'package:flutter/material.dart';

class DeleteButton extends StatefulWidget {
  final Future<void> Function() onConfirm;

  const DeleteButton({super.key, required this.onConfirm});

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          deleting
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
              : const Icon(Icons.delete, color: Colors.red),
      tooltip: "Delete",
      onPressed:
          deleting
              ? null
              : () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF181A1F),
                      title: const Text(
                        "Delete Product",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "Are you sure you want to delete this product?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  setState(() => deleting = true);
                  await widget.onConfirm();
                  setState(() => deleting = false);
                }
              },
    );
  }
}
