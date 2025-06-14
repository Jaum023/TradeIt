import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
  });

void _onItemTapped(BuildContext context, int index) async {
  switch (index) {
    case 0:
      Navigator.pushNamed(context, '/home');
      break;
    case 1:
      Navigator.pushNamed(context, '/create');
      break;
    case 2:
      Navigator.pushNamed(context, '/inbox');
      break;
    case 3:
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushNamed(context, '/profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faça login para acessar o perfil!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Criar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}