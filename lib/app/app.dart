import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import 'router.dart';

class ExoraApp extends StatelessWidget {
  const ExoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        scaffoldBackgroundColor: AppColors.backgroundTop,
        useMaterial3: true,
      ),
      initialRoute: AppRouter.authGate,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}