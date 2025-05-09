import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_google.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/register_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart'; 

class AuthController {
  final LoginWithEmail loginWithEmail;
  final LoginWithGoogle loginWithGoogle;
  final RegisterWithEmail? registerWithEmail;

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtPasswordConfirm = TextEditingController();
  final txtName = TextEditingController();
  final birthDateController = TextEditingController();

  AuthController.login({
    required this.loginWithEmail,
    required this.loginWithGoogle,
  }) : registerWithEmail = null;  // Não precisa de registerWithEmail no login
  AuthController.register({
    required this.loginWithEmail,
    required this.loginWithGoogle,
    required this.registerWithEmail,  // Passa registerWithEmail no registro
  });

  Future<void> registerUser(BuildContext context) async {
  try {
    final AppUser? user = await registerWithEmail!(
      txtEmail.text.trim(),
      txtPassword.text.trim(),
    );

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao registrar: $e')),
    );
  }
}

  Future<void> login(BuildContext context) async {
    try {
      final AppUser? user = await loginWithEmail(txtEmail.text.trim(), txtPassword.text.trim());
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login: $e")),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final AppUser? user = await loginWithGoogle();
      if (user != null) {
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