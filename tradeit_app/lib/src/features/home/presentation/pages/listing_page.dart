import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/shared/globalUser.dart';

class ListingPage extends StatefulWidget {
  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

    final adsStream = query.isEmpty
        ? FirebaseFirestore.instance.collection('ads').snapshots()
        : FirebaseFirestore.instance
            .collection('ads')
            .where('titleLowercase', isGreaterThanOrEqualTo: query)
            .where('titleLowercase', isLessThanOrEqualTo: query + '\uf8ff')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar anúncio...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                'TradeIt',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: true,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: adsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Nenhum dado disponível."));
          }

          // 🔥 Filtra os anúncios que NÃO são do usuário atual
          final firebaseData = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['ownerId'] != currentUser?.id;
          }).toList();

          if (firebaseData.isEmpty) {
            return Center(child: Text("Nenhum anúncio disponível de outros usuários."));
          }

          return ListView.builder(
            itemCount: firebaseData.length,
            itemBuilder: (context, index) {
              var ad = firebaseData[index];
              final data = ad.data() as Map<String, dynamic>?;

              return Container(
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  subtitle: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          data?['title'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        SizedBox(height: 4),
                        Text(data?['description'] ?? ''),
                        SizedBox(height: 4),
                        Text(
                          "Categoria: " + (data?['category'] ?? ''),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: {'adId': ad.id, 'ownerId': data?['ownerId']},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),
    );
  }
}
