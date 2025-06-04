import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/shared/globalUser.dart';
import 'package:tradeit_app/src/features/favorites/presentation/widgets/favorite_button.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Future<List<Map<String, dynamic>>> fetchFavoriteAds() async {
    final favSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.id)
            .collection('favorites')
            .get();

    final adIds = favSnapshot.docs.map((doc) => doc.id).toList();

    List<Map<String, dynamic>> ads = [];

    for (String adId in adIds) {
      final adSnapshot =
          await FirebaseFirestore.instance.collection('ads').doc(adId).get();

      if (adSnapshot.exists) {
        ads.add({'adId': adId, 'data': adSnapshot.data()});
      }
    }

    return ads;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meus Favoritos")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFavoriteAds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar favoritos."));
          }

          final favoriteAds = snapshot.data ?? [];

          if (favoriteAds.isEmpty) {
            return Center(child: Text("Nenhum favorito encontrado."));
          }

          return ListView.builder(
            itemCount: favoriteAds.length,
            itemBuilder: (context, index) {
              final ad = favoriteAds[index];
              final data = ad['data'] as Map<String, dynamic>;
              final images = List<String>.from(data['imageUrls'] ?? []);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {'adId': ad['adId'], 'ownerId': data['ownerId']},
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child:
                            images.isNotEmpty
                                ? Image.network(
                                  images.first,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                )
                                : Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Icon(
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Localização: (exemplo)",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Categoria: ${data['category'] ?? ''}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: FavoriteButton(adId: ad['adId']),
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
    );
  }
}
