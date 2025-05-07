import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatelessWidget{
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
              },
            child: const Text("Entrar"),
            ),
          SizedBox(height: 10), // spacing between buttons
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text("Registrar Conta"),
            ),
          ],
        ),
      ),
    );
  }
}