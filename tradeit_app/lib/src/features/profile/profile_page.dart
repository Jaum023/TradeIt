import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                child:
                    fotoUrl == null ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('  Favoritos  '),
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Meus anúncios",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('ads')
                      .where('ownerId', isEqualTo: currentUser?.id)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar anúncios.'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('Você ainda não criou nenhum anúncio.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: {
                            'adId': docs[index].id,
                            'ownerId': data['ownerId'],
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child:
                                  (data['imageUrls'] != null &&
                                          (data['imageUrls'] as List)
                                              .isNotEmpty)
                                      ? Image.network(
                                        (data['imageUrls'] as List).first,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.high,
                                      )
                                      : Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                        ),
                                      ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['location'] ?? 'Localização não disponível',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Categoria: ${data['category'] ?? ''}",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
