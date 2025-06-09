// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_google.dart';
import 'package:tradeit_app/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tradeit_app/src/features/auth/data/datasources/firebase_auth_datasource.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthRepositoryImpl authRepository;
  late final AuthController authController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
  super.initState();

  final datasource = FirebaseAuthDatasource();

  authRepository = AuthRepositoryImpl(datasource);
  authController = AuthController.login(
  loginWithEmail: LoginWithEmail(authRepository),
  loginWithGoogle: LoginWithGoogle(authRepository),
);
}

  @override
  void dispose() {
    authController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 35),
              AuthTextField(
                controller: authController.txtEmail,
                hint: "Email",
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
                controller: authController.txtPassword,
                hint: "Senha",
                icon: Icons.lock,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.login(context);
                    }
                  },
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  const Text(
                    'Faça login por',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => authController.signInWithGoogle(context),
                        icon: SizedBox(
                          height: 50,
                          child: Image.asset('assets/images/google_logo.png'),
                        ),
                      ),
                      IconButton(
                        onPressed: null,
                        icon: SizedBox(
                          height: 60,
                          child: Image.asset('assets/images/facebook_logo.png'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ainda não criou sua conta?',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(5),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text("Registre-se"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}