
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';

abstract class AuthDatasource {
  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> registerWithEmail(String email, String password, String name);
  Future<void> logout();
  AppUser? get currentAppUser;
}