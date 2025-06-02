import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/shared/globalUser.dart';

class ListingPage extends StatefulWidget {
  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String selectedCategory = '';

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.devices, 'label': 'Eletrônicos'},
    {'icon': Icons.checkroom, 'label': 'Roupas'},
    {'icon': Icons.chair, 'label': 'Móveis'},
    {'icon': Icons.menu_book, 'label': 'Livros'},
    {'icon': Icons.category, 'label': 'Outros'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

  Query adsQuery = FirebaseFirestore.instance.collection('ads');

  if (query.isNotEmpty) {
    adsQuery = adsQuery
      .where('titleLowercase', isGreaterThanOrEqualTo: query)
      .where('titleLowercase', isLessThanOrEqualTo: query + '\uf8ff');
}

  if (selectedCategory.isNotEmpty) {
    adsQuery = adsQuery.where('category', isEqualTo: selectedCategory);
}

    final adsStream = adsQuery.snapshots();

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
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Filtros por categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category['label'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : Colors.black,
                      size: 20,
                    ),
                    label: Text(category['label']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[200],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCategory = selectedCategory == category['label'] ? '' : category['label'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Lista de anúncios
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                final firebaseData = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  return data?['ownerId'] != currentUser?.id;
                }).toList();

                if (firebaseData.isEmpty) {
                  return Center(child: Text("Nenhum anúncio disponível para os filtros aplicados."));
                }

          return ListView.builder(
            itemCount: firebaseData.length,
            itemBuilder: (context, index) {
              var ad = firebaseData[index];
              final data = ad.data() as Map<String, dynamic>?;
              final List<String> images = List<String>.from(data?['imageUrls'] ?? []);

                    return Container(
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images.first,
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
                              Text(
                                data?['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              SizedBox(height: 4),
                              Text(data?['description'] ?? ''),
                              SizedBox(height: 4),
                              Text(
                                "Categoria: ${data?['category'] ?? ''}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),
    );
  }
}
