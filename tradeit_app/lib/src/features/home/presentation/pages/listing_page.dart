import 'package:flutter/material.dart';

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
    );
  }
}
