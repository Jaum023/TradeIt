import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tradeit_app/src/features/chat/domain/entities/chat_message.dart';

class ChatPage extends StatefulWidget {
  final String proposta;
<<<<<<< Updated upstream
  final String usuario;
  final List<ChatMessage> mensagensIniciais;
  
  const ChatPage({
    super.key,
    required this.proposta,
    required this.usuario,
    required this.mensagensIniciais,
=======
  final String otherUserUid;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.proposta,
    required this.otherUserUid,
    required this.otherUserName,
>>>>>>> Stashed changes
  });

  @override
  State<ChatPage> createState() => _ChatPage();
}

<<<<<<< Updated upstream
class _ChatPage extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late List<ChatMessage> _messages;
=======
class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
<<<<<<< Updated upstream
    // Mensagens iniciais + proposta base
    _messages = [
      ChatMessage(
        text: 'oi amigo',
        isMe: false,
        time: 'ONTEM',
        sender: widget.usuario,
      ),
      ...widget.mensagensIniciais,
    ];
=======
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
>>>>>>> Stashed changes
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

<<<<<<< Updated upstream
  void _enviarMensagem() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isMe: true,
          time: _formatarHora(DateTime.now()),
          sender: 'Você',
=======
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentUid = currentUser.uid;
      final currentName = currentUser.displayName ?? 'Usuário';

      await _db.collection('messages').add({
        'message': text,
        'user_name': currentName,
        'uid': currentUid,
        'timestamp': FieldValue.serverTimestamp(),
        'proposta': widget.proposta,
        'usuarios': [currentUid, widget.otherUserUid],
        'nomes': [currentName, widget.otherUserName],
      });

      final inboxId = _getInboxId(currentUid, widget.otherUserUid);
      await _db.collection('inbox').doc(inboxId).set({
        'proposta': widget.proposta,
        'usuarios': [currentUid, widget.otherUserUid],
        'nomes': [currentName, widget.otherUserName],
        'ultimaMensagem': text,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar mensagem: ${e.toString()}'),
          backgroundColor: Colors.red,
>>>>>>> Stashed changes
        ),
      );
    });

    _messageController.clear();
  }

<<<<<<< Updated upstream
  String _formatarHora(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate.isAtSameMomentAs(today)) {
      return 'HOJE';
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 1)))) {
      return 'ONTEM';
    } else {
      return DateFormat('dd/MM').format(time);
    }
=======
  String _getInboxId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return uids.join('_');
>>>>>>> Stashed changes
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Enviando...';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    } catch (e) {
      return 'Enviando...';
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
=======
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Usuário não autenticado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

>>>>>>> Stashed changes
    return Scaffold(
      backgroundColor: const Color(0xFF1B202D),
      appBar: AppBar(
<<<<<<< Updated upstream
        backgroundColor: const Color(0xFF1B202D),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.usuario,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.proposta.split(' - ')[0], 
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message, index);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        if (index == 0 || 
            _messages[index].time != _messages[index-1].time)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.time,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
=======
        title: Text('Chat - ${widget.otherUserName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
>>>>>>> Stashed changes
          ),
        
        // Bubble dos amigos
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: 
                message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2A9D8F),
                  child: Text(
                    message.sender.isNotEmpty ? message.sender[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFF2A9D8F)
                        : const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: 
                          message.isMe ? const Radius.circular(12) : const Radius.circular(4),
                      bottomRight: 
                          message.isMe ? const Radius.circular(4) : const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.sender.isNotEmpty && !message.isMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.sender,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              onSubmitted: (_) => _enviarMensagem(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2A9D8F)),
            onPressed: _enviarMensagem,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('messages')
                    .where('proposta', isEqualTo: widget.proposta)
                    .where('usuarios', arrayContains: currentUid)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar mensagens',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Envie a primeira mensagem!'),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isCurrentUser = data['uid'] == currentUid;

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
                                ? Theme.of(context).primaryColor.withOpacity(0.8)
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
                              if (!isCurrentUser)
                                Text(
                                  data['user_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                data['message'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isCurrentUser ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(data['timestamp'] as Timestamp?),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isCurrentUser
                                      ? Colors.white70
                                      : Colors.black54,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}
