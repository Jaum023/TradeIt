// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
      body: Column(
        children: [
          SizedBox(height: 50),
          SizedBox(
            height: 200,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 35),
          Container(
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
                    //validator: (value) {   DESATIVANDO PARA FACILITAR OS TESTES
                      //if (value == null || value.isEmpty) return 'Campo obrigatório';
                      //if (!value.contains('@')) return 'Email inválido';
                      //return null;
                    //},
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: controller.txtPassword,
                    hint: "Senha",
                    icon: Icons.lock,
                    obscure: true,
                    //validator: (value) {   DESATIVANDO PARA FACILITAR OS TESTES
                      //if (value == null || value.length < 6) return 'Senha muito curta';
                      //return null;
                    //},
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, "/home");
                        }
                      },
                      child: const Text("Login", style: TextStyle(fontSize: 18),),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text('Faça login por', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: null, icon: SizedBox(height: 50,child: Image.asset('assets/images/google_logo.png'))),
                          IconButton(onPressed: null, icon: SizedBox(height: 60,child: Image.asset('assets/images/facebook_logo.png')))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Ainda não criou sua conta?', style: TextStyle(color: Colors.blueGrey)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, "/register"),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          minimumSize: Size(0, 0),

                        ),
                        child: Text("Registre-se"),
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