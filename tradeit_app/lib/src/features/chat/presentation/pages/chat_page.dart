import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String proposta;
  final String usuario; // Nome do outro usuário

  const ChatPage({super.key, required this.proposta, required this.usuario});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      // Salva a mensagem
      await _db.collection('messages').add({
        'message': text,
        'user_name': _auth.currentUser?.displayName ?? 'Usuário',
        'uid': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'proposta': widget.proposta,
        'usuarios': [
          _auth.currentUser!.uid,
          widget.usuario, // Aqui pode ser o UID do outro usuário se você tiver, ajuste conforme seu modelo!
        ],
        'nomes': [
          _auth.currentUser?.displayName ?? 'Você',
          widget.usuario,
        ],
      });

      // Atualiza/Cria resumo na inbox
      final inboxId = _getInboxId(_auth.currentUser!.uid, widget.usuario);
      await _db.collection('inbox').doc(inboxId).set({
        'proposta': widget.proposta,
        'usuarios': [
          _auth.currentUser!.uid,
          widget.usuario,
        ],
        'nomes': [
          _auth.currentUser?.displayName ?? 'Você',
          widget.usuario,
        ],
        'ultimaMensagem': text,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  // Gera um ID único para a conversa entre dois usuários
  String _getInboxId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return uids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.usuario}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('messages')
                  .where('proposta', isEqualTo: widget.proposta)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar mensagens: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem ainda.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isCurrentUser = data['uid'] == currentUid;
                    String timestampString = 'Enviando...';
                    final timestamp = data['timestamp'];
                    if (timestamp is Timestamp) {
                      try {
                        timestampString = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
                      } catch (_) {
                        timestampString = 'Enviando...';
                      }
                    }

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue[200]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                            bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['message'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timestampString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}