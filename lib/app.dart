import 'package:flutter/material.dart';
import 'package:lsrd_pro/features/auth/login_screen.dart';
import 'package:lsrd_pro/features/dashboard/dashboard_screen.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

class LDMSProApp extends StatelessWidget {
  const LDMSProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDMS Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}