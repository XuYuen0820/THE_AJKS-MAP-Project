import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init notice (running in offline demo mode until project connected): $e');
  }
  runApp(const ExoraApp());
}

class ExoraApp extends StatelessWidget {
  const ExoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
        ),
        scaffoldBackgroundColor: AppColors.backgroundTop,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
