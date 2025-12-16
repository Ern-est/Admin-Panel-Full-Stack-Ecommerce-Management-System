import 'package:flutter/material.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1113),
      body: Center(
        child: Text(
          "You are not authorized to access this page.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
