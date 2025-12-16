import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const RefreshButton({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh, color: Colors.green),
      tooltip: "Refresh",
      onPressed: () => onRefresh(),
    );
  }
}
