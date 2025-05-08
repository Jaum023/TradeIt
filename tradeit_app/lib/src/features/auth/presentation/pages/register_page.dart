// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/birth_date_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 25,),
                  Text('Cadastro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 25,),
                  Text('Faça seu cadastro', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  SizedBox(height: 65,),
                  AuthTextField(
                    controller: controller.txtName,
                    hint: "Digite seu nome",
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) { 
                      if (value == null || value.isEmpty) return 'Campo obrigatório';
                      return null;
                    },
                  ),
                  SizedBox(height: 8,),
                  AuthTextField(
                    controller: controller.txtEmail,
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
                    controller: controller.txtPassword,
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
                    controller: controller.txtPasswordConfirm,
                    hint: "Confirme sua senha",
                    icon: Icons.lock,
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obrigatório';
                      if (value != controller.txtPassword.text) return 'As senhas não são iguais';
                      return null;
                    },
                  ),
                  SizedBox(height: 8,),
                  BirthDateField(
                    controller: controller.birthDateController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione sua data de nascimento';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18,),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, "/home");
                        }
                      },
                      child: const Text("Registrar", style: TextStyle(fontSize: 18),),
                    ),
                  ),
                  SizedBox(height: 15),
                  Column(
                    children: [
                      Text('Registre-se por', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: null, icon: SizedBox(height: 50,child: Image.asset('assets/images/google_logo.png'))),
                          IconButton(onPressed: null, icon: SizedBox(height: 60,child: Image.asset('assets/images/facebook_logo.png')))
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

