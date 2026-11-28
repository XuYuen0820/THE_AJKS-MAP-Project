import 'package:get_it/get_it.dart';

import '../core/services/auth_service.dart';
import '../core/services/firebase_auth_service.dart';
import '../features/authentication/viewmodels/auth_viewmodel.dart';
import '../features/authentication/viewmodels/forgot_password_viewmodel.dart';
import '../features/authentication/viewmodels/login_viewmodel.dart';
import '../features/collection_assignment/services/collection_assignment_service.dart';
import '../features/collection_assignment/services/firebase_collection_assignment_service.dart';
import '../features/collection_assignment/viewmodels/collection_assignment_viewmodel.dart';
import '../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../features/profile/services/firebase_profile_service.dart';
import '../features/profile/services/profile_service.dart';
import '../features/profile/viewmodels/profile_viewmodel.dart';

final GetIt dependency = GetIt.instance;

void init() {
  // 1. Services
  dependency.registerLazySingleton<AuthService>(() => FirebaseAuthService());
  dependency.registerLazySingleton<ProfileService>(
    () => FirebaseProfileService(),
  );
  dependency.registerLazySingleton<CollectionAssignmentService>(
    () => FirebaseCollectionAssignmentService(),
  );

  // 2. ViewModels
  dependency.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(dependency<AuthService>()),
  );
  dependency.registerFactory<LoginViewModel>(
    () => LoginViewModel(dependency<AuthService>()),
  );
  dependency.registerFactory<ForgotPasswordViewModel>(
    () => ForgotPasswordViewModel(dependency<AuthService>()),
  );
  dependency.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      dependency<AuthService>(),
      dependency<ProfileService>(),
    ),
  );
  dependency.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      dependency<ProfileService>(),
      dependency<AuthService>(),
    ),
  );
  dependency.registerFactory<CollectionAssignmentViewModel>(
    () => CollectionAssignmentViewModel(
      dependency<CollectionAssignmentService>(),
    ),
  );
}
