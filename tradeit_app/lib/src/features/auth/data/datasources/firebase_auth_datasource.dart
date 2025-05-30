// lib/src/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_datasource.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart'; 

class FirebaseAuthDatasource implements AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser _mapFirebaseUserToAppUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
  );
} 

  @override
  Future<AppUser?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = result.user;
    return user != null ? _mapFirebaseUserToAppUser(user) : null;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final result = await _auth.signInWithPopup(GoogleAuthProvider());
    final user = result.user;
    return user != null ? _mapFirebaseUserToAppUser(user) : null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<AppUser?> registerWithEmail(String email, String password, String name) async {
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return _mapFirebaseUserToAppUser(user);
    }
    return null;
  }

  @override
  AppUser? get currentAppUser {
  final user = _auth.currentUser;
  return user != null ? _mapFirebaseUserToAppUser(user) : null;
}
}