import '../../data/datasources/auth_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeit_app/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<User?> loginWithEmail(String email, String password) {
    return datasource.signInWithEmail(email, password);
  }

  @override
  Future<User?> loginWithGoogle() {
    return datasource.signInWithGoogle();
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Future<User?> registerWithEmail(String email, String password) {
  return datasource.registerWithEmail(email, password);
}

  @override
  User? getCurrentUser() {
    return datasource.currentUser;
  }
}