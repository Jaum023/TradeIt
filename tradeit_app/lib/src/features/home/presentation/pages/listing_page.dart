import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
<<<<<<< Updated upstream
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/pages/product_detail.dart';
import 'package:tradeit_app/shared/globalUser.dart';
import 'package:cached_network_image/cached_network_image.dart';


final FirebaseFirestore firestore = FirebaseFirestore.instance;
>>>>>>> Stashed changes

class ListingPage extends StatelessWidget {
  final List<Map<String, String>> anuncios = [
    {
      'titulo': 'Bicicleta',
      'descricao': 'Bicicleta aro 26 em ótimo estado, aceito skate como troca.',
    },
    {
      'titulo': 'Livro de romance',
      'descricao': 'Livro novo, troco por outro em bom estado.',
    },
    {
      'titulo': 'Smartphone antigo',
      'descricao': 'Aparelho funcionando, ideal como reserva.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Troca de Produtos'),
      //   backgroundColor: Colors.teal,
      // ),
      body: ListView.builder(
        itemCount: anuncios.length,
        itemBuilder: (context, index) {
          final anuncio = anuncios[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(anuncio['titulo']!),
              subtitle: Text(anuncio['descricao']!),
              leading: Icon(Icons.swap_horiz, color: Colors.deepPurple),
              onTap: () {
                Navigator.pushNamed(context, '/details', arguments:{'tituloProduto': anuncio['titulo'], 'descricaoProduto': anuncio['descricao']});
              },
            ),
          );
        },
      ),
<<<<<<< Updated upstream
=======
      body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('ads').snapshots(), 
        builder: (context, snapshot){
          if(snapshot.hasError) return Center(child: Text("Erro ${snapshot.error}"));

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Nenhum dado disponível."));
          }
          final firebaseData = snapshot.data!.docs;

          return ListView.builder(itemCount: firebaseData.length, itemBuilder: (context, index){
            var ad = firebaseData[index];
            final data = ad.data() as Map<String, dynamic>?;
            final List<String> images = List<String>.from(data?['imageUrls'] ?? []);
            // final userName = getUser(data?['ownerId']) as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1)
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: images.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image, size: 60, color: Colors.grey),
                subtitle: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  
                      Text(data?['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                      SizedBox(height: 4),
                      
                      Text(data?['description']),
                      SizedBox(height: 4),

                      Text("Categoria: " + data?['category'], style: TextStyle(color: Colors.grey[700]))
                    
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/details', arguments: {'adId': ad.id, 'ownerId':  data?['ownerId']});
                },
              ),
            );
          });
        }
        
      ), 
>>>>>>> Stashed changes
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),

    );
  }
}
