import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'features/auth/login_view.dart';
import 'features/dashboard/admin_dashboard_view.dart';
import 'features/dashboard/invigilator_dashboard_view.dart';
import 'firebase_options.dart';
import 'models/staff_user.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AuthService().configureWebPersistence();

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        scaffoldBackgroundColor: AppColors.backgroundTop,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = authSnapshot.data;
        final email = firebaseUser?.email;
        if (firebaseUser == null || email == null || email.isEmpty) {
          return const LoginView();
        }

        return FutureBuilder<StaffUser>(
          future: authService.fetchStaffProfile(email),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not load your staff profile: ${profileSnapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => authService.signOut(),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final staffUser = profileSnapshot.data!;
            if (!staffUser.isActive) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('This staff account has been deactivated.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => authService.signOut(),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (staffUser.role.toLowerCase() == 'admin') {
              return AdminDashboardView(user: staffUser);
            }
            return InvigilatorDashboardView(user: staffUser);
          },
        );
      },
    );
  }
}
