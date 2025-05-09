// lib/src/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_datasource.dart';

class FirebaseAuthDatasource implements AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  @override
  Future<User?> signInWithGoogle() async {
    final result = await _auth.signInWithPopup(GoogleAuthProvider());
    return result.user;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
  final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return result.user;
}

  @override
  User? get currentUser => _auth.currentUser;
}