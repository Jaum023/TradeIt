import 'package:flutter/material.dart';
import 'chat_page.dart'; // Assumindo que a TelaChat esteja no mesmo diretório

class InboxPage extends StatelessWidget {
  InboxPage({super.key});

  // Dados fictícios (simulando o backend)
  final List<Map<String, dynamic>> propostas = [
    {
      'titulo': 'LIVRO - BICICLETA',
      'ultimaMensagem': 'oi amigo',
      'usuario': 'CARLOS',
      'hora': '10:30',
    },
    {
      'titulo': 'VIOLÃO - BICICLETA',
      'ultimaMensagem': 'É uma marca boa esse meu violão!',
      'usuario': 'GILMAR',
      'hora': 'Ontem',
    },
  ];

  // Função para formatar a hora
  String _formatarHora(String hora) {
    if (hora == 'Ontem') {
      return 'Ontem';
    }
    return 'Hoje às $hora'; // Exibe a hora para o caso de ser "Hoje"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B202D),
      appBar: AppBar(
        title: const Text("Propostas", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B202D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: propostas.length,
        itemBuilder: (context, index) {
          final proposta = propostas[index];
          return _buildProposta(
            titulo: proposta['titulo'],
            ultimaMensagem: proposta['ultimaMensagem'],
            hora: proposta['hora'],
            onTap: () {
              // Passando as mensagens para a TelaChat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    proposta: proposta['titulo'],
                    usuario: proposta['usuario'],
                    mensagensIniciais: [
                      // Mensagens iniciais simuladas
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProposta({
    required String titulo,
    required String ultimaMensagem,
    required String hora,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            ultimaMensagem,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _formatarHora(hora), // Usando a função de formatação de hora
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white12, height: 20),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String sender;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.sender,
  });
}