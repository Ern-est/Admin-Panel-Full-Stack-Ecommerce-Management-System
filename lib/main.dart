import 'package:admin_panel/auth/admin_login_screen.dart';
import 'package:admin_panel/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/navigation_controller.dart';
import 'core/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppConfig (loads .env and sets up Supabase)
  await AppConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkBase = ThemeData.dark();

    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: darkBase.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f0f12),
        textTheme: GoogleFonts.poppinsTextTheme(darkBase.textTheme),
        colorScheme: darkBase.colorScheme.copyWith(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Decides which screen to show based on auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final session = AppConfig.supabase.auth.currentSession;

    if (session != null) {
      _authenticated = true; // user exists if session exists
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show onboarding first if not authenticated
    if (!_authenticated) {
      return const OnboardingScreen();
    }

    // If authenticated, show role selection
    return const LoginScreen();
  }
}
