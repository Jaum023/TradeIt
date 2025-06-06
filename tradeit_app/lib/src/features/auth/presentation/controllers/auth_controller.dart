import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_google.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/register_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';
import '../../../../../shared/globalUser.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/logout.dart';

class AuthController {
  final LoginWithEmail? loginWithEmail;
  final LoginWithGoogle? loginWithGoogle;
  final RegisterWithEmail? registerWithEmail;
  final Logout? logoutUseCase;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtPasswordConfirm = TextEditingController();
  final txtName = TextEditingController();
  final birthDateController = TextEditingController();

  // Construtor para login
  AuthController.login({
    required this.loginWithEmail,
    required this.loginWithGoogle,
  }) : registerWithEmail = null,
       logoutUseCase = null;

  // Construtor para registro
  AuthController.register({
    required this.loginWithEmail,
    required this.loginWithGoogle,
    required this.registerWithEmail,
  }) : logoutUseCase = null;

  // Construtor para logout
  AuthController.logout({required this.logoutUseCase})
    : registerWithEmail = null,
      loginWithEmail = null,
      loginWithGoogle = null;

  Future<AppUser?> loadUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return AppUser(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Future<void> registerUser(BuildContext context) async {
    if (txtEmail.text.trim().isEmpty || txtPassword.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail e senha são obrigatórios')),
      );
      return;
    }

    try {
      final AppUser? user = await registerWithEmail!(
        txtEmail.text.trim(),
        txtPassword.text.trim(),
        txtName.text.trim(),
      );

      if (user != null) {
        // após registrar, faça o login com email/senha
        await login(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar: $e')));
    }
  }

  Future<void> login(BuildContext context) async {
    if (txtEmail.text.trim().isEmpty || txtPassword.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail e senha são obrigatórios')),
      );
      return;
    }

    if (loginWithEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login com email não está disponível')),
      );
      return;
    }

    try {
      final AppUser? user = await loginWithEmail!(
        txtEmail.text.trim(),
        txtPassword.text.trim(),
      );
      if (user != null) {
        final profile = await loadUserProfile(user.id);
        currentUser = profile ?? user;
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao fazer login: $e")));
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso!')),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (loginWithGoogle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login com Google não está disponível')),
      );
      return;
    }

    try {
      final AppUser? user = await loginWithGoogle!();
      if (user != null) {
        final profile = await loadUserProfile(user.id);
        currentUser = profile ?? user;
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login com Google: $e")),
      );
    }
  }

  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    txtPasswordConfirm.dispose();
    txtName.dispose();
    birthDateController.dispose();
  }
}
