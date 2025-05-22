import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/globalUser.dart';

class ProductDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final adId = args?['adId'].toString();
    
    //aqui pega o id de quem criou o anuncio e pega o id global do usuario logado
    final ownerId = args?['ownerId'].toString();
    final isOwner = ownerId == currentUser?.id; 

    if (adId == null) {
      return Scaffold(body: Center(child: Text('ID não encontrado')));
    }  

    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Produto")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('ads').doc(adId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Anúncio não encontrado')) ;
          }

          if (snapshot.hasError)
            return Center(child: Text("Erro: ${snapshot.error}"));

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final createdAt = data['createdAt'];
          final date = DateTime.parse(createdAt);
          final formattedDate = DateFormat('dd/mm/yyyy').format(date!);


          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem do produto
              SizedBox(height: 20),
              Center(child: Text("Imagem Produto")),
              SizedBox(height: 25),
              // Nome do produto
              Text(
                (data['title'] != null && data['title'].toString().isNotEmpty)
                  ? "Título: " + data['title']
                  : 'Título não disponível',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              SizedBox(height: 10),

              // Usuário e cidade
              // Text("Anunciado por: $nomeUsuario", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              // Text("Localização: $cidade", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 20),

              // Descrição
              Text(
                (data['description'] != null && data['description'].toString().isNotEmpty)
                  ? "Descrição: " + data['description']
                  : 'Descrição não disponível',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                (data['category'] != null && data['category'].toString().isNotEmpty)
                  ? "Categoria: " + data['category']
                  : 'Categoria não disponível',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Criado em: " + formattedDate,
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 40),


              Center(
                child: ElevatedButton.icon(
                  icon: Icon(isOwner ? Icons.edit : Icons.swap_horiz),
                  label: Text(isOwner ? "Editar Anúncio" : "Propor Troca"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOwner ? Colors.orange : Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    if (isOwner) {
                      Navigator.pushNamed(context, '/edit', arguments: data); // ou adId
                    } else {
                      Navigator.pushNamed(context, '/chat_teste', arguments: data); // ou adId
                    }
                  },
                ),
              ),

            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 3),
    );
  }
}
