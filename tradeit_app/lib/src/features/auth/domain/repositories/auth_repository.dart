import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> loginWithEmail(String email, String password);
  Future<AppUser?> loginWithGoogle();
  Future<AppUser?> registerWithEmail(String email, String password, String name);
  Future<void> logout();
  AppUser? get currentUser;
}