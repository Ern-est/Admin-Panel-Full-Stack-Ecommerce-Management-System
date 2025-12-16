import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final List<String> menuTitles;
  final Function(int index) onMenuSelected;

  const AdminSidebar({
    super.key,
    required this.menuTitles,
    required this.onMenuSelected,
  });

  IconData _getIcon(String title) {
    switch (title) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'Products':
        return Icons.category;
      case 'Categories':
        return Icons.list_alt;
      case 'Sub Categories':
        return Icons.subdirectory_arrow_right;
      case 'Brands':
        return Icons.branding_watermark;
      case 'Variant Types':
        return Icons.tune;
      case 'Variants':
        return Icons.format_list_bulleted;
      case 'Banners':
        return Icons.image;
      case 'Discounts':
        return Icons.discount;
      case 'Ratings':
        return Icons.star_half;
      case 'Orders':
        return Icons.shopping_bag;
      case 'Notifications':
        return Icons.notifications;
      case 'Settings':
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            for (int i = 0; i < menuTitles.length; i++)
              _menuItem(_getIcon(menuTitles[i]), menuTitles[i], i),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, int index) {
    return InkWell(
      onTap: () => onMenuSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
