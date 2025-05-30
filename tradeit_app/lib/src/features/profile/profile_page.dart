import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tradeit_app/src/features/auth/domain/usecases/logout.dart';
import 'package:tradeit_app/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tradeit_app/src/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:tradeit_app/shared/globalUser.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> {
  late final AuthController authController;
  late final AuthRepositoryImpl authRepository;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepositoryImpl(FirebaseAuthDatasource());
    authController = AuthController.logout(
      logoutUseCase: Logout(authRepository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nome = currentUser?.name ?? 'Nome não disponível';
    final String email = currentUser?.email ?? 'Email não disponível';
    final String? fotoUrl = null; //currentUser?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authController.logoutUser(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    fotoUrl != null ? NetworkImage(fotoUrl) : null,
                child: fotoUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Segredo dos amigos')),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 3),
    );
  }
}
