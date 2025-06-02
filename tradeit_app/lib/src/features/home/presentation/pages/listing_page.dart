import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/shared/globalUser.dart';
import 'package:intl/intl.dart';

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
        title:
            _isSearching
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
          const SizedBox(height: 10),
          // Filtros por categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children:
                  categories.map((category) {
                    final isSelected = selectedCategory == category['label'];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        4.0,
                        4.0,
                        4.0,
                        4.0,
                      ),
                      child: ElevatedButton.icon(
                        icon: Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : Colors.black,
                          size: 20,
                        ),
                        label: Text(category['label']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSelected
                                  ? const Color.fromARGB(255, 110, 53, 209)
                                  : const Color.fromARGB(255, 255, 255, 255),
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedCategory =
                                selectedCategory == category['label']
                                    ? ''
                                    : category['label'];
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 10),
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

                final firebaseData =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      return data?['ownerId'] != currentUser?.id;
                    }).toList();

                if (firebaseData.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhum anúncio disponível para os filtros aplicados.",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: firebaseData.length,
                  itemBuilder: (context, index) {
                    var ad = firebaseData[index];
                    final data = ad.data() as Map<String, dynamic>?;
                    final List<String> images = List<String>.from(
                      data?['imageUrls'] ?? [],
                    );

                    final createdAt = data?['createdAt'];
                    DateTime? date;
                    String formattedDate = '';

                    if (createdAt != null) {
                      try {
                        if (createdAt is Timestamp) {
                          date = createdAt.toDate();
                        } else {
                          date = DateTime.tryParse(createdAt.toString());
                        }

                        if (date != null) {
                          formattedDate = DateFormat('dd/MM/yyyy').format(date);
                        }
                      } catch (_) {}
                    }

                    return GestureDetector(
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
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagem do anúncio
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
                                    data?['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Categoria: ${data?['category'] ?? ''}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Condição: ${data?['condition'] ?? ''}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Localização: (exemplo)",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "Criado em: $formattedDate",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: StatefulBuilder(
                                      builder: (context, setFavState) {
                                        bool isFavorited = false;
                                        return IconButton(
                                          icon: Icon(
                                            Icons.favorite,
                                            color:
                                                isFavorited
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                          onPressed: () {
                                            setFavState(() {
                                              isFavorited = !isFavorited;
                                            });
                                          },
                                        );
                                      },
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
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),
    );
  }
}
