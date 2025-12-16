import 'package:admin_panel/widgets/unauthorized_page.dart';
import 'package:flutter/material.dart';

class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final String? role; // ✅ rename to `role` to match usage

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.role, // optional, nullable
  });

  @override
  Widget build(BuildContext context) {
    if (role == null || !allowedRoles.contains(role)) {
      return const UnauthorizedPage();
    }
    return child;
  }
}
