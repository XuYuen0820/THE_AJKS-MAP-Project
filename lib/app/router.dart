import 'package:flutter/material.dart';

import '../core/models/staff_user.dart';
import '../features/authentication/views/auth_gate_view.dart';
import '../features/authentication/views/forgot_password_view.dart';
import '../features/authentication/views/login_view.dart';
import '../features/dashboard/views/admin_dashboard_view.dart';
import '../features/dashboard/views/invigilator_dashboard_view.dart';
import '../features/invigilator_management/views/assign_invigilator_view.dart';
import '../features/invigilator_management/views/discharge_invigilator_view.dart';
import '../features/invigilator_management/views/invigilator_list_view.dart';
import '../features/invigilator_management/views/invigilator_management_view.dart';
import '../features/profile/views/edit_profile_view.dart';
import '../features/profile/views/profile_view.dart';
import 'dependencies.dart';

class AppRouter {
  static const String authGate = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String adminDashboard = '/admin-dashboard';
  static const String invigilatorDashboard = '/invigilator-dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String invigilatorManagement = '/invigilator-management';
  static const String invigilatorList = '/invigilator-list';
  static const String assignInvigilator = '/assign-invigilator';
  static const String dischargeInvigilator = '/discharge-invigilator';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(
          builder: (_) => AuthGateView(viewModel: dependency()),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginView(viewModel: dependency()),
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordView(viewModel: dependency()),
        );
      case adminDashboard:
        final user = settings.arguments as StaffUser;
        return MaterialPageRoute(
          builder: (_) =>
              AdminDashboardView(user: user, viewModel: dependency()),
        );
      case invigilatorDashboard:
        final user = settings.arguments as StaffUser;
        return MaterialPageRoute(
          builder: (_) =>
              InvigilatorDashboardView(user: user, viewModel: dependency()),
        );
      case profile:
        final user = settings.arguments as StaffUser;
        return MaterialPageRoute(
          builder: (_) => ProfileView(user: user, viewModel: dependency()),
        );
      case editProfile:
        final user = settings.arguments as StaffUser;
        return MaterialPageRoute(
          builder: (_) => EditProfileView(user: user, viewModel: dependency()),
        );
      case invigilatorManagement:
        return MaterialPageRoute(
          builder: (_) => const InvigilatorManagementView(),
        );
      case invigilatorList:
        return MaterialPageRoute(
          builder: (_) => InvigilatorListView(viewModel: dependency()),
        );
      case assignInvigilator:
        return MaterialPageRoute(
          builder: (_) => AssignInvigilatorView(viewModel: dependency()),
        );
      case dischargeInvigilator:
        return MaterialPageRoute(
          builder: (_) => DischargeInvigilatorView(viewModel: dependency()),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
