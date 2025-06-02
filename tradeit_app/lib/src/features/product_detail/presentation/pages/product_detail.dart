import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/controller/produtController.dart';
import '../../../../../shared/globalUser.dart';

class ProductDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final adId = args?['adId'].toString();
    final ownerId = args?['ownerId'].toString();
    final isOwner = ownerId == currentUser?.id;

    if (adId == null) {
      return Scaffold(body: Center(child: Text('ID não encontrado')));
    }

    final controller = Get.put(ProductDetailController(adId), tag: adId);

    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Produto")),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('ads').doc(adId).get(),
        builder: (context, snapshot) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text("Erro: ${controller.errorMessage.value}"));
          }

          final data = controller.adData.value;

          if (data == null) {
            return Center(child: Text('Anúncio não encontrado'));
          }

          final createdAt = data['createdAt'];
          final date = DateTime.tryParse(createdAt ?? '');
          final formattedDate = date != null
              ? DateFormat('dd/MM/yyyy').format(date)
              : 'Data inválida';

          final List<String> images = List<String>.from(data['imageUrls'] ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Imagem do produto
                if (images.isNotEmpty)
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, idx) => Image.network(
                        images[idx],
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Título
                      Text(
                        data['title'] ?? 'Título não disponível',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      SizedBox(height: 8),


                      SizedBox(height: 16),
                      Divider(),

                      // Criador
                      Text('Criado por:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                        data['userName'] ?? 'Criador do anúncio não encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "localizacao teste: cidade X, estado",
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Descrição
                      Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                        data['description'] ?? 'Descrição não disponível',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Categoria
                      Text('Categoria:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                        data['category'] ?? 'Categoria não disponível',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Data de criação
                      Text('Criado em:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 30),

                      // Botão de ação
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(isOwner ? Icons.edit : Icons.swap_horiz),
                          label: Text(isOwner ? "Editar Anúncio" : "Propor Troca"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOwner ? Colors.orange : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          onPressed: () {
                            if (isOwner) {
                              Navigator.pushNamed(
                                context,
                                '/edit',
                                arguments: {'dataProduct': data, 'adId': adId},
                              );
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/chat_teste',
                                arguments: data,
                              );
                            }
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 3),
    );
  }
}
