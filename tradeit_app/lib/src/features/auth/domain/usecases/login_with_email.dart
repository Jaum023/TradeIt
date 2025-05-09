import '../repositories/auth_repository.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart'; 

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<AppUser?> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}