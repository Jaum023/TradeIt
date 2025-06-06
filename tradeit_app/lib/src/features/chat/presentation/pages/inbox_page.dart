// Importações necessárias para o funcionamento da página de inbox
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para acessar o banco de dados em nuvem
import 'package:firebase_auth/firebase_auth.dart'; // Para verificar qual usuário está logado
import 'package:intl/intl.dart'; // Para formatar data e hora
import 'chat_page.dart'; // Página do chat para abrir ao clicar em uma conversa
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart'; // Barra inferior personalizada

// Página sem estado, usada para listar todas as conversas do usuário atual
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  // Função que conta quantas mensagens ainda não foram lidas em um chat específico
  Future<int> _contarNaoLidas(String chatId, String meuUid) async {
    final snap = await FirebaseFirestore.instance
        .collection('mensagens') // Acessa a coleção de mensagens
        .where('chatId', isEqualTo: chatId) // Filtra pelo chat atual
        .where('lidasPor', whereNotIn: [meuUid]) // Verifica se o usuário ainda não leu
        .get();
    return snap.docs.length; // Retorna a quantidade de mensagens não lidas
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser; // Usuário logado
    final currentUid = currentUser?.uid; // UID do usuário

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Propostas", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      // Usa StreamBuilder para acompanhar mudanças em tempo real da coleção "inbox"
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inbox')
            .where('usuarios', arrayContains: currentUid) // Mostra apenas conversas do usuário atual
            .orderBy('timestamp', descending: true) // Mais recentes primeiro
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Erro ao carregar dados: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // Carregando
          }

          final propostas = snapshot.data!.docs; // Lista de conversas

          if (propostas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma conversa ainda.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          // Cria a lista de conversas
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: propostas.length,
            itemBuilder: (context, index) {
              final propostaData = propostas[index].data() as Map<String, dynamic>;
              final nomes = (propostaData['nomes'] as List<dynamic>?) ?? [];
              final uids = (propostaData['usuarios'] as List<dynamic>?) ?? [];
              final chatId = propostaData['chatId'] ?? '';

              // Valida dados básicos
              if (nomes.isEmpty || uids.isEmpty) {
                return const SizedBox();
              }

              // Identifica o nome do outro usuário na conversa
              final otherUserName = nomes.firstWhere(
                (n) => n != currentUser?.displayName,
                orElse: () => 'Outro usuário',
              );

              // Identifica o UID do outro usuário na conversa
              final otherUserUid = uids.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );

              // Formata a data da última mensagem
              final hora = propostaData['timestamp'] != null
                  ? _formatarHora((propostaData['timestamp'] as Timestamp).toDate())
                  : 'Agora';

              // Usa FutureBuilder para contar mensagens não lidas e exibir um indicador
              return FutureBuilder<int>(
                future: _contarNaoLidas(chatId, currentUid!),
                builder: (context, snapshot) {
                  final naoLidas = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      _buildProposta(
                        titulo: propostaData['proposta'] ?? 'Proposta sem título',
                        ultimaMensagem: propostaData['ultimaMensagem'] ?? '',
                        hora: hora,
                        usuario: otherUserName.toString(),
                        onTap: () {
                          // Abre a página de chat ao clicar na conversa
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                proposta: propostaData['proposta'] ?? '',
                                outroUsuarioUid: otherUserUid.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                      // Se houver mensagens não lidas, exibe o contador em vermelho
                      if (naoLidas > 0)
                        Positioned(
                          right: 16,
                          top: 16,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              '$naoLidas',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      // Barra inferior personalizada
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }

  // Função auxiliar para formatar a data de exibição no card
  String _formatarHora(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date); // Ex: 14:35
    } else if (messageDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM').format(date); // Ex: 06/06
    }
  }

  // Constrói visualmente cada item da lista de propostas
  Widget _buildProposta({
    required String titulo,
    required String ultimaMensagem,
    required String hora,
    required String usuario,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
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
          ultimaMensagem,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          maxLines: 1, // Mostra só uma linha da última mensagem
          overflow: TextOverflow.ellipsis, // Se for muito longa, coloca "..."
        ),
        trailing: Text(
          hora,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        onTap: onTap, // Ação ao clicar na conversa
      ),
    );
  }
}

// Variável global que pode ser usada para rastrear o chat atualmente aberto
String? currentOpenChatId;
void setCurrentOpenChatId(String? chatId) {
  currentOpenChatId = chatId; // Define o ID do chat atualmente aberto
}