import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String chatId; // ID do chat na coleção 'inbox'
  final String proposta;
  final String outroUsuarioUid;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.proposta,
    required this.outroUsuarioUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controllerMensagem = TextEditingController();
  bool _chatFinalizado = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _verificarStatusChat();
  }

  Future<void> _verificarStatusChat() async {
    final doc = await FirebaseFirestore.instance
        .collection('inbox')
        .doc(widget.chatId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['status'] == 'finalizado') {
        setState(() {
          _chatFinalizado = true;
        });
      }
    }
  }

  Future<void> _enviarMensagem() async {
    final texto = _controllerMensagem.text.trim();
    if (texto.isEmpty || _chatFinalizado) return;

    final now = DateTime.now();

    // Atualiza subcoleção 'mensagens' no chat
    await FirebaseFirestore.instance
        .collection('inbox')
        .doc(widget.chatId)
        .collection('mensagens')
        .add({
      'remetente': currentUser?.uid,
      'texto': texto,
      'timestamp': now,
    });

    // Atualiza dados principais do chat: última mensagem e timestamp
    await FirebaseFirestore.instance
        .collection('inbox')
        .doc(widget.chatId)
        .update({
      'ultimaMensagem': texto,
      'timestamp': now,
    });

    _controllerMensagem.clear();
  }

  // Função para exibir modal e finalizar chat
  Future<void> _finalizarChat() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar chat'),
        content: const Text('Deseja realmente finalizar essa conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Atualiza o status do chat para "finalizado"
      await FirebaseFirestore.instance
          .collection('inbox')
          .doc(widget.chatId)
          .update({'status': 'finalizado'});

      setState(() {
        _chatFinalizado = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat finalizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proposta),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Finalizar chat',
            onPressed: _chatFinalizado ? null : _finalizarChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inbox')
                  .doc(widget.chatId)
                  .collection('mensagens')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensagens = snapshot.data!.docs;

                if (mensagens.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem ainda.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msgData =
                        mensagens[index].data()! as Map<String, dynamic>;
                    final texto = msgData['texto'] ?? '';
                    final remetente = msgData['remetente'] ?? '';
                    final timestamp = msgData['timestamp'] as Timestamp?;

                    final bool isMe = remetente == currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent.withOpacity(0.8)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              texto,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            if (timestamp != null)
                              Text(
                                DateFormat('HH:mm')
                                    .format(timestamp.toDate()),
                                style: TextStyle(
                                  color: (isMe
                                          ? Colors.white70
                                          : Colors.black54)
                                      .withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_chatFinalizado)
            Container(
              padding: const EdgeInsets.all(16),
              // ignore: deprecated_member_use
              color: Colors.red.withOpacity(0.1),
              child: const Text(
                'Este chat foi finalizado e não aceita mais mensagens.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _controllerMensagem,
                      enabled: !_chatFinalizado,
                      readOnly: _chatFinalizado,
                      decoration: InputDecoration(
                        // _chatFinalizado ? 'Chat finalizado' : 
                        hintText: 'Digite sua mensagem...',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _enviarMensagem(),
                    ),

                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: !_chatFinalizado ? Colors.blue : Colors.grey,
                  onPressed: _chatFinalizado ? null : _enviarMensagem,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
