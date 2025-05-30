import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/pages/product_detail.dart';
import 'package:tradeit_app/shared/globalUser.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<Map<String, dynamic>?> getUser(String ownerId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
  return doc.data();
}


class ListingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TradeIt'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4.0, // sombra inferior
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // ação futura de busca
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Erro ${snapshot.error}"));

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Nenhum dado disponível."));
          }
          final firebaseData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: firebaseData.length,
            itemBuilder: (context, index) {
              var ad = firebaseData[index];
              final data = ad.data() as Map<String, dynamic>?;

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUser(
                  data?['ownerId'],
                ), // sua função que busca o usuário
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return ListTile(title: Text('Erro ao carregar usuário'));
                  }

                  final user = snapshot.data!;
                  final nome =
                      user['name']; 

                  return Container(
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(data?['description'] ?? ''),
                          SizedBox(height: 4),
                          Text(
                            "Criado por: $nome",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text("Categoria: ${data?['category'] ?? ''}"),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: {
                            'adId': ad.id,
                            'ownerId': data?['ownerId'],
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),
    );
  }
}
