import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String proposta;
  final String usuario;
  final List<ChatMessage> mensagensIniciais;
  
  const ChatPage({
    super.key,
    required this.proposta,
    required this.usuario,
    required this.mensagensIniciais,
  });

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
        ),
      );
    });

    _messageController.clear();
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B202D),
      appBar: AppBar(
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
    this.sender = '',
  });
}
