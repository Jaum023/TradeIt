// 'StateNotifier/Notifier com lógica de UI'
import 'package:flutter/material.dart';

class AuthController {
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();

  Future<void> login(BuildContext context) async {
    // Aqui você chamaria o usecase ou repositório de login no futuro
    print('Login com: ${txtEmail.text} / ${txtPassword.text}');
    Navigator.pushReplacementNamed(context, "/chat");
  }

  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
  }
}