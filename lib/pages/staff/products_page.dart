import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(title: const Text('Products')),
      body: const Center(
        child: Text(
          'Products List Coming Soon 🛒',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
