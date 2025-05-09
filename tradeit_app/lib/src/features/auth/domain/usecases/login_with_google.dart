import '../repositories/auth_repository.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart'; 

class LoginWithGoogle {
  final AuthRepository repository;

  LoginWithGoogle(this.repository);

  Future<AppUser?> call() {
    return repository.loginWithGoogle();
  }
}