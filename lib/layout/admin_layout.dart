import 'package:admin_panel/widgets/ratings_page.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';
import '../services/user_service.dart';
import '../models/app_user.dart';
import '../widgets/role_guard.dart';

// Pages
import '../pages/dashboard_page.dart';
import '../pages/products_page.dart';
import '../pages/categories_page.dart';
import '../pages/sub_categories_page.dart';
import '../pages/brands_page.dart';
import '../pages/variant_types_page.dart';
import '../pages/variants_page.dart';
import '../pages/banners_page.dart';
import '../pages/discounts_page.dart';
import '../pages/orders_page.dart';
import '../pages/notifications_page.dart';
import '../pages/settings_page.dart';

class AdminLayout extends StatefulWidget {
  final String role; // "admin" or "staff"
  const AdminLayout({super.key, required this.role});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int selectedIndex = 0;
  AppUser? currentUser;
  bool loading = true;

  late List<String> menuTitles;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final user = await UserService.getCurrentUser();
    if (!mounted) return;

    setState(() {
      currentUser = user;

      // ----- Define role-based menu & pages -----
      if (user?.role == 'admin') {
        menuTitles = [
          'Dashboard',
          'Products',
          'Categories',
          'Sub Categories',
          'Brands',
          'Variant Types',
          'Variants',
          'Banners',
          'Discounts',
          'Ratings',
          'Orders',
          'Notifications',
          'Settings',
        ];
      } else {
        menuTitles = ['Dashboard', 'Orders', 'Notifications', 'Settings'];
      }

      // Map titles to pages and wrap with RoleGuard
      final Map<String, Widget> pageMapping = {
        'Dashboard': RoleGuard(
          allowedRoles: ['admin', 'staff'],
          child: DashboardPage(),
          role: user?.role,
        ),
        'Products': RoleGuard(
          allowedRoles: ['admin'],
          child: ProductsPage(),
          role: user?.role,
        ),
        'Categories': RoleGuard(
          allowedRoles: ['admin'],
          child: CategoriesPage(),
          role: user?.role,
        ),
        'Sub Categories': RoleGuard(
          allowedRoles: ['admin'],
          child: SubCategoriesPage(),
          role: user?.role,
        ),
        'Brands': RoleGuard(
          allowedRoles: ['admin'],
          child: BrandsPage(),
          role: user?.role,
        ),
        'Variant Types': RoleGuard(
          allowedRoles: ['admin'],
          child: VariantTypesPage(),
          role: user?.role,
        ),
        'Variants': RoleGuard(
          allowedRoles: ['admin'],
          child: VariantsPage(),
          role: user?.role,
        ),
        'Banners': RoleGuard(
          allowedRoles: ['admin'],
          child: BannersPage(),
          role: user?.role,
        ),
        'Discounts': RoleGuard(
          allowedRoles: ['admin'],
          child: DiscountsPage(),
          role: user?.role,
        ),
        'Ratings': RoleGuard(
          allowedRoles: ['admin'],
          child: RatingsPage(),
          role: user?.role,
        ),
        'Orders': RoleGuard(
          allowedRoles: ['admin', 'staff'],
          role: user?.role, // ✅ role comes before child
          child: OrdersPage(role: user?.role ?? 'staff'), // pass the role
        ),

        'Notifications': RoleGuard(
          allowedRoles: ['admin', 'staff'],
          child: NotificationsPage(),
          role: user?.role,
        ),
        'Settings': RoleGuard(
          allowedRoles: ['admin', 'staff'],
          child: SettingsPage(),
          role: user?.role,
        ),
      };

      // Build pages list dynamically based on allowed menu
      pages = menuTitles.map((title) => pageMapping[title]!).toList();

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            menuTitles: menuTitles,
            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Container(color: Colors.black, child: pages[selectedIndex]),
          ),
        ],
      ),
    );
  }
}
