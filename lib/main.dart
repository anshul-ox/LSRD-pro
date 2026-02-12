import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/lsr_provider.dart';
import 'package:lsrd_pro/features/auth/login_screen.dart';
import 'package:lsrd_pro/features/dashboard/dashboard_screen.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => LSRProvider()..initialize(),
      child: const LDMSProApp(),
    ),
  );
}

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
