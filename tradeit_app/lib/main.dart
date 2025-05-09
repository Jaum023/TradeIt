import 'package:flutter/material.dart';
import 'src/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDf5E2dJWRsBt3cxL7isnBOdKJDa7q9Deg",
      authDomain: "tradeit-66fdf.firebaseapp.com",
      projectId: "tradeit-66fdf",
      storageBucket: "tradeit-66fdf.firebasestorage.app",
      messagingSenderId: "148647717463",
      appId: "1:148647717463:web:c759495c56d43b11129112",
    )
  );
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