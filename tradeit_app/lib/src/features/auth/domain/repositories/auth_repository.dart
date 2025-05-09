import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> loginWithEmail(String email, String password);
  Future<User?> loginWithGoogle();
  Future<User?> registerWithEmail(String email, String password);
  Future<void> logout();
  User? getCurrentUser();
}