import 'package:flutter/material.dart';

import '../core/models/staff_user.dart';
import '../features/authentication/views/auth_gate_view.dart';
import '../features/authentication/views/forgot_password_view.dart';
import '../features/authentication/views/login_view.dart';
import '../features/collection_assignment/models/collection_area_assignment.dart';
import '../features/collection_assignment/viewmodels/collection_assignment_viewmodel.dart';
import '../features/collection_assignment/views/assign_area_view.dart';
import '../features/collection_assignment/views/collection_assignment_view.dart';
import '../features/collection_assignment/views/edit_assignment_view.dart';
import '../features/dashboard/views/admin_dashboard_view.dart';
import '../features/dashboard/views/invigilator_dashboard_view.dart';
import '../features/dashboard/views/lead_invigilator_dashboard_view.dart';
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
  static const String collectionAssignment = '/collection-assignment';
  static const String assignArea = '/assign-area';
  static const String editAssignment = '/edit-assignment';

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
        if (user.role.trim().toLowerCase() == 'lead invigilator') {
          return MaterialPageRoute(
            builder: (_) => LeadInvigilatorDashboardView(
              user: user,
              viewModel: dependency(),
            ),
          );
        }
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
      case collectionAssignment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CollectionAssignmentView(
            user: args['user'] as StaffUser,
            examId: (args['examId'] as String?) ?? 'exam001',
            viewModel: dependency(),
          ),
        );
      case assignArea:
        final vm = settings.arguments as CollectionAssignmentViewModel;
        return MaterialPageRoute(builder: (_) => AssignAreaView(viewModel: vm));
      case editAssignment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditAssignmentView(
            viewModel: args['viewModel'] as CollectionAssignmentViewModel,
            assignment: args['assignment'] as CollectionAreaAssignment,
          ),
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
