import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco como na ProductDetail
      appBar: AppBar(
        title: const Text("Propostas", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white, // AppBar branca
        iconTheme: const IconThemeData(color: Colors.black87), // Ícones escuros
        elevation: 1, // Sombra sutil como na ProductDetail
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('inbox')
                .where('usuarios', arrayContains: currentUid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          debugPrint('Snapshot connection state: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            debugPrint('Erro ao carregar dados: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            debugPrint('Snapshot ainda não tem dados.');
            return const Center(child: CircularProgressIndicator());
          }
          debugPrint('Dados recebidos: ${snapshot.data!.docs.length}');

          final propostasRaw = snapshot.data!.docs;

          //aqui ta dando b.o no inbox, nao aparece a 1 mensagem e a proposta
          final propostas = propostasRaw.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != 'finalizado';
          }).toList();

          for (var proposta in propostas) {
            debugPrint('Documento recebido: ${proposta.data()}');
          }
          if (propostas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma conversa ainda.',
                style: TextStyle(color: Colors.black54), // Texto cinza
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: propostas.length,
            itemBuilder: (context, index) {
              final propostaData =
                  propostas[index].data() as Map<String, dynamic>;
              final nomes = (propostaData['nomes'] as List<dynamic>?) ?? [];
              final uids = (propostaData['usuarios'] as List<dynamic>?) ?? [];
              debugPrint('UID atual: $currentUid');

              if (nomes.isEmpty || uids.isEmpty) {
                debugPrint('Documento inválido: ${propostaData}');
                return const SizedBox(); // Ignora documentos inválidos
              }

              final currentUserName = currentUser?.displayName ?? '';
              final meuIndice = nomes.indexOf(currentUserName);
              final nomeOutroUsuario = (meuIndice == 0) ? nomes[1] : nomes[0];

              final otherUserUid = uids.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );

              final hora =
                  propostaData['timestamp'] != null
                      ? _formatarHora(
                        (propostaData['timestamp'] as Timestamp).toDate(),
                      )
                      : 'Agora';

              final tituloConcatenado = '$nomeOutroUsuario - ${propostaData['proposta'] ?? 'Proposta sem título'}';

              return _buildProposta(
                titulo: tituloConcatenado,
                ultimaMensagem: propostaData['ultimaMensagem'] ?? '',
                hora: hora,
                usuario: nomeOutroUsuario.toString(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: propostas[index].id,  // aqui, o id do documento do chat
                        proposta: propostaData['proposta'] ?? '',
                        outroUsuarioUid: otherUserUid.toString(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }

  String _formatarHora(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  Widget _buildProposta({
    required String titulo,
    required String ultimaMensagem,
    required String hora,
    required String usuario,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1, // Sombra sutil
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$ultimaMensagem',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          hora,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        onTap: onTap,
      ),
    );
  }
}
