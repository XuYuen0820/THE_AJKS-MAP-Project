import 'package:flutter/material.dart';

import '../../../app/dependencies.dart';
import '../../dashboard/views/admin_dashboard_view.dart';
import '../../dashboard/views/invigilator_dashboard_view.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';

class AuthGateView extends StatelessWidget {
  final AuthViewModel viewModel;

  const AuthGateView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewModel.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.signOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = viewModel.currentUser;
        if (user == null) {
          return LoginView(viewModel: dependency());
        }

        if (user.role.toLowerCase() == 'admin') {
          return AdminDashboardView(user: user, viewModel: dependency());
        }
        return InvigilatorDashboardView(user: user, viewModel: dependency());
      },
    );
  }
}
