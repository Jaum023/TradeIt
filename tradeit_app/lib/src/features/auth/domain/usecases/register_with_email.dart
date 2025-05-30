import '../repositories/auth_repository.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart'; 

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<AppUser?> call(String email, String password, String name) {
    return repository.registerWithEmail(email, password, name);
  }
}