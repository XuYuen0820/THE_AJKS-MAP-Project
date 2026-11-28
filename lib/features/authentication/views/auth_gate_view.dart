import 'package:flutter/material.dart';

import '../../../app/dependencies.dart';
import '../../dashboard/views/admin_dashboard_view.dart';
import '../../dashboard/views/invigilator_dashboard_view.dart';
import '../../dashboard/views/lead_invigilator_dashboard_view.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';

class AuthGateView extends StatefulWidget {
  final AuthViewModel viewModel;

  const AuthGateView({super.key, required this.viewModel});

  @override
  State<AuthGateView> createState() => _AuthGateViewState();
}

class _AuthGateViewState extends State<AuthGateView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = widget.viewModel.currentUser;
        if (user == null) {
          return LoginView(viewModel: dependency());
        }

        final roleLower = user.role.trim().toLowerCase();
        if (roleLower == 'admin') {
          return AdminDashboardView(user: user, viewModel: dependency());
        }
        if (roleLower == 'lead invigilator') {
          return LeadInvigilatorDashboardView(
            user: user,
            viewModel: dependency(),
          );
        }
        return InvigilatorDashboardView(user: user, viewModel: dependency());
      },
    );
  }
}
