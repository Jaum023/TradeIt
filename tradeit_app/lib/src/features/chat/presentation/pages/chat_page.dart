import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String proposta;
  final String outroUsuarioUid;

  const ChatPage({
    super.key,
    required this.proposta,
    required this.outroUsuarioUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _messageController = TextEditingController();
  late final String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = _gerarChatId(_auth.currentUser!.uid, widget.outroUsuarioUid);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensagem() async {
    if (_messageController.text.isEmpty) return;

    try {
      // Adiciona um pequeno delay para evitar timestamp nulo
      await Future.delayed(const Duration(milliseconds: 500));

      await _db.collection('mensagens').add({
        'texto': _messageController.text,
        'de': _auth.currentUser!.uid,
        //'deNome': _auth.currentUser!.displayName ?? 'Usuário', N utilizei a final mas é possivel usar dps
        'para': widget.outroUsuarioUid,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': _chatId,
        'proposta': widget.proposta,
      });
      final inboxQuery =
          await FirebaseFirestore.instance
              .collection('inbox')
              .where('chatId', isEqualTo: _chatId)
              .limit(1)
              .get();

      if (inboxQuery.docs.isNotEmpty) {
        await inboxQuery.docs.first.reference.update({
          'ultimaMensagem': '${_auth.currentUser!.displayName ?? 'Usuário'}: ${_messageController.text}',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: ${e.toString()}')),
      );
    }
  }

  String _gerarChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final meuUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.proposta}'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Adicione ação adicional se necessário
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _db
                      .collection('mensagens')
                      .where('chatId', isEqualTo: _chatId)
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar mensagens\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nEnvie a primeira mensagem!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isEu = msg['de'] == meuUid;
                    final timestamp = msg['timestamp'] as Timestamp?;

                    return Align(
                      alignment:
                          isEu ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isEu ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['texto']),
                            if (timestamp != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _formatarData(timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _enviarMensagem(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm - dd/MM').format(date);
  }
}
