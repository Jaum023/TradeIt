import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDatasource {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> registerWithEmail(String email, String password);
  Future<void> logout();
  User? get currentUser;
}