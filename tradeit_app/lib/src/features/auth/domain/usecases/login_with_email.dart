import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<User?> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}