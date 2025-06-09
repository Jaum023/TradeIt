// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/birth_date_field.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_email.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/login_with_google.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/register_with_email.dart';
import 'package:tradeit_app/src/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:tradeit_app/src/features/auth/data/repositories/auth_repository_impl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthController authController;
  late final AuthRepositoryImpl authRepository;

  @override
  void initState() {
  super.initState();
  authRepository = AuthRepositoryImpl(FirebaseAuthDatasource());
  authController = AuthController.register(
  loginWithEmail: LoginWithEmail(authRepository),
  loginWithGoogle: LoginWithGoogle(authRepository),
  registerWithEmail: RegisterWithEmail(authRepository),
  );
  }

  final _formKey = GlobalKey<FormState>();

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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),
              const Text(
                'Cadastro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              const Text(
                'Faça seu cadastro',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 65),
              AuthTextField(
                controller: authController.txtName,
                hint: "Digite seu nome",
                icon: Icons.person,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              AuthTextField(
                controller: authController.txtPassword,
                hint: "Senha",
                icon: Icons.lock,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length < 6) return 'Senha muito curta';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              AuthTextField(
                controller: authController.txtPasswordConfirm,
                hint: "Confirme sua senha",
                icon: Icons.lock,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value != authController.txtPassword.text) return 'As senhas não são iguais';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              BirthDateField(
                controller: authController.birthDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione sua data de nascimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.registerUser(context);
                    }
                  },
                  child: const Text("Registrar", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    ),
  );
}

}

