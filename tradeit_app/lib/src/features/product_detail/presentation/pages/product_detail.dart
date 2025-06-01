import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
<<<<<<< Updated upstream
=======
import 'package:intl/intl.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/controller/produtController.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/controller/userAdProductController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../shared/globalUser.dart';
>>>>>>> Stashed changes

class ProductDetail extends StatelessWidget {

  final String nomeUsuario = "João Silva";
  final String cidade = "São Paulo, SP";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String? tituloProduto = args?['tituloProduto'];
    final String? descricaoProduto = args?['descricaoProduto'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Produto"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem do produto
            SizedBox(height: 20),
            Center(
              child: Text("Imagem Produto"),
             
            ),
            SizedBox(height: 25),
            // Nome do produto
            Text(tituloProduto ?? "Produto não encontrado", style: Theme.of(context).textTheme.headlineSmall),

            SizedBox(height: 10),
            // Usuário e cidade
            Text("Anunciado por: $nomeUsuario", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Text("Localização: $cidade", style: TextStyle(fontSize: 16, color: Colors.grey[700])),

            SizedBox(height: 20),

            // Descrição
            Text("Descrição: "),
            SizedBox(height: 8),
            Text(descricaoProduto ?? "Descrição não encontrada", style: TextStyle(fontSize: 16)),

<<<<<<< Updated upstream
            SizedBox(height: 40),
=======
          final List<String> images = List<String>.from(data['imageUrls'] ?? []);

          final List<String> images = List<String>.from(data['imageUrls'] ?? []);

          final List<String> images = List<String>.from(data['imageUrls'] ?? []);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem do produto
              SizedBox(height: 20),
              Center(child: Text("Imagem Produto")),
              SizedBox(height: 25),
              if (images.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, idx) => CachedNetworkImage(
                      imageUrl: images[idx],
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Center(child: Text("Sem imagem")),

              // Nome do produto
              Text(
                (data['title'] != null && data['title'].toString().isNotEmpty)
                  ? "Título: " + data['title']
                  : 'Título não disponível',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
>>>>>>> Stashed changes

            // Botão para propor troca
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.swap_horiz),
                label: Text("Propor Troca"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat_teste');
                  // Lógica para iniciar proposta de troca
                  // Exemplo: Navigator.pushNamed(context, '/propor-troca', arguments: produto);
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 3),
    );
  }
}
