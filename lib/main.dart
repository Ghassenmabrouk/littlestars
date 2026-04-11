import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/child_attendance_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/absence_history_screen.dart';
import 'models/models.dart';
import 'localization/app_strings.dart';
import 'theme/kg_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Jardin d\'Enfant Parent',
        theme: KG.theme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name == '/attendance_history') {
            final child = settings.arguments as Child;
            return MaterialPageRoute(
              builder: (context) => AttendanceHistoryScreen(child: child),
            );
          } else if (settings.name == '/absence_history') {
            final child = settings.arguments as Child;
            return MaterialPageRoute(
              builder: (context) => AbsenceHistoryScreen(child: child),
            );
          }
          return null;
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.restoreSession();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        isLoggedIn ? '/home' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: KG.primary),
            const SizedBox(height: 20),
            const Text(
              'Jardin d\'Enfant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
