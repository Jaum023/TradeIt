import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterPage extends StatelessWidget{
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
              },
            child: const Text("Criar conta"),
            ),
          SizedBox(height: 10), // spacing between buttons
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Voltar"),
            ),
          ],
        ),
      ),
    );
  }
}
