import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/controller/produtController.dart';
import '../../../../../shared/globalUser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductDetail extends StatelessWidget {

final TextEditingController _textController = TextEditingController();
  File? _imagemSelecionada;

  void _abrirModal(BuildContext context, String ownerId, String ownerName, controller) {
    final picker = ImagePicker();
    File? imagemSelecionada;
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _selecionarImagem() async {
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                setState(() {
                  imagemSelecionada = File(picked.path);
                });
              }
            }

            Future<void> _enviarProposta(String ownerId, String ownerName, controller) async {
              final uidAtual = currentUser?.id;
              final nomeAtual = currentUser?.name ?? 'Usuário';
              final outroUid = ownerId; // ID do dono do anúncio
              final outroNome = controller.adData.value['userName'] ?? 'Outro';

              if (_controller.text.trim().isEmpty) return;

              String? imagemUrl;
              // if (imagemSelecionada != null) {
              //   final ref = FirebaseStorage.instance
              //       .ref()
              //       .child('propostas')
              //       .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
              //   await ref.putFile(imagemSelecionada!);
              //   imagemUrl = await ref.getDownloadURL();
              // }

              await FirebaseFirestore.instance.collection('inbox').add({
                'proposta': currentUser!.name,
                'ultimaMensagem': _controller.text.trim(),
                'usuarios': [currentUser!.id, ownerId],
                'nomes': [currentUser!.name, ownerName],
                'timestamp': Timestamp.now(),
                'imagemUrl': imagemUrl ?? '',
              });

              Navigator.popAndPushNamed(context, '/home');
            }

            return AlertDialog(
              title: Text('Oferta para Anunciante:'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Faça sua oferta!",
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selecionarImagem,
                      child: Text("Selecionar Imagem"),
                    ),
                    if (imagemSelecionada != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.file(imagemSelecionada!, height: 100),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:(){ _enviarProposta(ownerId, ownerName, controller);},
                  child: Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
        future: FirebaseFirestore.instance.collection('ads').doc(adId).get(),
        builder: (context, snapshot) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text("Erro: ${controller.errorMessage.value}"),
            );
          }

          final data = controller.adData.value;

          if (data == null) {
            return Center(child: Text('Anúncio não encontrado'));
          }

          final createdAt = data['createdAt'];
          final date = DateTime.tryParse(createdAt ?? '');
          final formattedDate =
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Data inválida';

          final List<String> images = List<String>.from(
            data['imageUrls'] ?? [],
          );

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
                      itemBuilder:
                          (context, idx) =>
                              Image.network(images[idx], fit: BoxFit.cover),
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
                      Text(
                        'Criado por:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data['userName'] ?? 'Criador do anúncio não encontrado',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Descrição
                      Text(
                        'Descrição:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data['description'] ?? 'Descrição não disponível',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Categoria
                      Text(
                        'Categoria:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data['category'] ?? 'Categoria não disponível',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      // Data de criação
                      Text(
                        'Criado em:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(formattedDate, style: TextStyle(fontSize: 16)),

                      SizedBox(height: 16),
                      Divider(),

                      // Localização
                      Text(
                        'Localização:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data['location'] ?? 'Localização não disponível',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 30),

                      // Botão de ação
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(isOwner ? Icons.edit : Icons.swap_horiz),
                          label: Text(
                            isOwner ? "Editar Anúncio" : "Propor Troca",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isOwner ? Colors.orange : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
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
                                '/chat',
                                arguments: {
                                  'chatId':
                                      '${currentUser?.id}_${data['ownerId']}', // Geração simples do ID do chat
                                  'otherUserId':
                                      data['ownerId'], // Já existe desde a criação
                                  'otherUserName':
                                      data['userName'], // Já existe
                                  'proposta':
                                      'Interesse no item: ${data['title']}', // Mensagem padrão
                                  'relatedAdId': adId, // Vincula ao anúncio
                                },
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
