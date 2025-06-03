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
<<<<<<< Updated upstream
=======
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;

>>>>>>> Stashed changes
    return Scaffold(
      backgroundColor: const Color(0xFF1B202D),
      appBar: AppBar(
        title: const Text("Propostas", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B202D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
<<<<<<< Updated upstream
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
=======
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inbox')
            .where('usuarios', arrayContains: currentUid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final propostas = snapshot.data!.docs;
          if (propostas.isEmpty) {
            return const Center(
              child: Text('Nenhuma conversa ainda.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: propostas.length,
            itemBuilder: (context, index) {
              final propostaData =
                  propostas[index].data() as Map<String, dynamic>;
              final nomes = propostaData['nomes'] as List<dynamic>;
              final uids = propostaData['usuarios'] as List<dynamic>;

              final otherUserName = nomes.firstWhere(
                (n) => n != currentUser?.displayName,
                orElse: () => 'Outro usuário',
              );

              final otherUserUid = uids.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );

              return _buildProposta(
                titulo: propostaData['proposta'] ?? '',
                ultimaMensagem: propostaData['ultimaMensagem'] ?? '',
                hora: propostaData['timestamp'] != null &&
                        propostaData['timestamp'] is Timestamp
                    ? DateFormat('HH:mm').format(
                        (propostaData['timestamp'] as Timestamp).toDate())
                    : '',
                usuario: otherUserName,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        proposta: propostaData['proposta'],
                        otherUserUid: otherUserUid,
                        otherUserName: otherUserName,
                      ),
                    ),
                  );
                },
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

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
=======
>>>>>>> Stashed changes
