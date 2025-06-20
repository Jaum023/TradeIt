import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/controller/produtController.dart';
import '../../../../../shared/globalUser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tradeit_app/shared/cloudinary_helper.dart';

class ProductDetail extends StatelessWidget {

  ProductDetail({super.key});

  void _abrirModal(
    BuildContext context,
    String ownerId,
    String ownerName,
    String title,
    String adId, // <-- adicione este parâmetro
    controller,
  ) {
    final picker = ImagePicker();
    File? imagemSelecionada;
    final TextEditingController controller0 = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> selecionarImagem() async {
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                setState(() {
                  imagemSelecionada = File(picked.path);
                });
              }
            }

            Future<void> enviarProposta(
              String ownerId,
              String ownerName,
              String adId, // <-- adicione aqui
              controller,
            ) async {
              final uidAtual = currentUser?.id;
              final outroUid = ownerId;

              if (controller0.text.trim().isEmpty) return;

              String? imagemUrl;
              if (imagemSelecionada != null) {
                imagemUrl = await CloudinaryHelper.uploadImage(imagemSelecionada!);
              }

              final chatId = uidAtual!.compareTo(outroUid) < 0
                  ? '${uidAtual}_$outroUid'
                  : '${outroUid}_$uidAtual';

              // Cria/atualiza o documento do chat
              await FirebaseFirestore.instance.collection('inbox').doc(chatId).set({
                'chatId': chatId,
                'proposta': title,
                'ultimaMensagem': '${currentUser?.name ?? 'Usuário'}: ${controller0.text.trim()}',
                'usuarios': [currentUser!.id, ownerId],
                'nomes': [currentUser!.name, ownerName],
                'timestamp': Timestamp.now(),
                'imagemUrl': imagemUrl ?? '',
                'status': 'ativo',
              });

              // Cria a mensagem na subcoleção 'mensagens'
              await FirebaseFirestore.instance
                  .collection('inbox')
                  .doc(chatId)
                  .collection('mensagens')
                  .add({
                'remetente': currentUser?.id,
                'texto': controller0.text.trim(),
                'imagemUrl': imagemSelecionada != null ? imagemUrl ?? '' : '',
                'timestamp': Timestamp.now(),
              });

              Navigator.popAndPushNamed(context, '/chat', arguments: {
                'chatId': chatId,
                'proposta': title,
                'outroUsuarioUid': ownerId,
              });
            }

            Future<void> converterMensagem(
              String ownerId,
              String ownerName,
              String textoProposta,
            ) async {
              final uidAtual = currentUser?.id;
              final outroUid = ownerId;

              if (uidAtual == null || textoProposta.isEmpty) return;

              final chatId = uidAtual.compareTo(outroUid) < 0
                  ? '${uidAtual}_$outroUid'
                  : '${outroUid}_$uidAtual';

              await FirebaseFirestore.instance.collection('mensagens').add({
                'texto': textoProposta,
                'de': uidAtual,
                'para': outroUid,
                'timestamp': FieldValue.serverTimestamp(),
                'chatId': chatId,
                'proposta': 'Interesse no item',
              });
            }

            return AlertDialog(
              title: const Text('Oferta para Anunciante:'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller0,
                      decoration: const InputDecoration(
                        labelText: "Faça sua oferta!",
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selecionarImagem,
                      child: const Text("Selecionar Imagem"),
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
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final texto = controller0.text.trim();
                    await enviarProposta(ownerId, ownerName, adId, controller);
                    await converterMensagem(ownerId, ownerName, texto);
                  },
                  child: const Text('Enviar'),
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
      return const Scaffold(body: Center(child: Text('ID não encontrado')));
    }

    final controller = Get.put(ProductDetailController(adId), tag: adId);

    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes do Produto")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('ads').doc(adId).get(),
        builder: (context, snapshot) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text("Erro: ${controller.errorMessage.value}"),
            );
          }

          final data = controller.adData.value;

          if (data == null) {
            return const Center(child: Text('Anúncio não encontrado'));
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
                    child: const Center(
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

                      const SizedBox(height: 8),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Criador
                      const Text(
                        'Criado por:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['userName'] ?? 'Criador do anúncio não encontrado',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Descrição
                      const Text(
                        'Descrição:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['description'] ?? 'Descrição não disponível',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Categoria
                      const Text(
                        'Categoria:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['category'] ?? 'Categoria não disponível',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Data de criação
                      const Text(
                        'Criado em:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: const TextStyle(fontSize: 16)),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Localização
                      const Text(
                        'Localização:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['location'] ?? 'Localização não disponível',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 30),

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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () {
                            // if (isOwner) {
                            //   Navigator.pushNamed(
                            //     context,
                            //     '/edit',
                            //     arguments: {'dataProduct': data, 'adId': adId},
                            //   );
                            // } else {
                            //   Navigator.pushNamed(
                            //     context,
                            //     '/chat',
                            //     arguments: {
                            //       'chatId':
                            //           '${currentUser?.id}_${data['ownerId']}', // Geração simples do ID do chat
                            //       'otherUserId':
                            //           data['ownerId'], // Já existe desde a criação
                            //       'otherUserName':
                            //           data['userName'], // Já existe
                            //       'proposta':
                            //           'Interesse no item: ${data['title']}', // Mensagem padrão
                            //       'relatedAdId': adId, // Vincula ao anúncio
                            //     },
                            //   );
                            // }
                            if (isOwner) {
                              Navigator.pushNamed(
                                context,
                                '/edit',
                                arguments: {'dataProduct': data, 'adId': adId},
                              );
                            } else {
                              // Propor troca
                              _abrirModal(
                                context,
                                ownerId!,
                                data['userName'] ?? 'Usuário Desconhecido',
                                data['title'] ?? 'Título não disponível',
                                adId, 
                                controller,
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
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 3),
    );
  }
}
