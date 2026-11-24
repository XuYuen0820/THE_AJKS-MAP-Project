import 'package:firebase_auth/firebase_auth.dart';

import '../models/staff_user.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  Future<void> configureWebPersistence();
  Future<void> login({required String email, required String password});
  Future<void> sendPasswordResetEmail(String email);
  Future<StaffUser> fetchStaffProfile(String email);
  Future<void> signOut();
}
