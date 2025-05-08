import 'package:flutter/material.dart';
import 'src/routes/routes.dart';

void main() {
  runApp(const TradeItApp());
}

class TradeItApp extends StatelessWidget {
  const TradeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TradeIt',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: ('Montserrat'),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Ponto de entrada do app
      routes: routes, // Todas as rotas registradas
    );
  }
}