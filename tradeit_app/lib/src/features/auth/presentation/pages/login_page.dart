import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTextField(
                controller: controller.txtEmail,
                hint: "E-mail",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AuthTextField(
                controller: controller.txtPassword,
                hint: "Senha",
                icon: Icons.lock,
                obscure: true,
                validator: (value) {
                  if (value == null || value.length < 6) return 'Senha muito curta';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(context, "/home");
                  }
                },
                child: const Text("Login"),
              ),
              TextButton(
                child: const Text("Registre-se"),
                onPressed: () => Navigator.pushNamed(context, "/register"),
              )
            ],
          ),
        ),
      ),
    );
  }
}