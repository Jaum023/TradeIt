import '../../data/datasources/auth_datasource.dart';
import 'package:tradeit_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
final AuthDatasource datasource;

AuthRepositoryImpl(this.datasource);

@override
Future<AppUser?> loginWithEmail(String email, String password) {
return datasource.signInWithEmail(email, password);
}

@override
Future<AppUser?> loginWithGoogle() {
return datasource.signInWithGoogle();
}

@override
Future<AppUser?> registerWithEmail(String email, String password) {
return datasource.registerWithEmail(email, password);
}

@override
Future logout() {
return datasource.logout();
}

@override
AppUser? get currentUser => datasource.currentAppUser;
}