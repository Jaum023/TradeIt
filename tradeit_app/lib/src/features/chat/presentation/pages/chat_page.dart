// Importa bibliotecas essenciais do Flutter e Firebase
import 'package:flutter/material.dart'; // UI do aplicativo
import 'package:cloud_firestore/cloud_firestore.dart'; // Banco de dados em tempo real
import 'package:firebase_auth/firebase_auth.dart'; // Autenticação do usuário
import 'package:intl/intl.dart'; // Formatação de datas
import 'package:tradeit_app/shared/current_chat.dart'; // Gerencia o ID do chat atual
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Notificações locais
import 'package:tradeit_app/main.dart'; // Plugin de notificação definido na main.dart
import 'dart:io'; // Manipulação de arquivos locais
import 'package:image_picker/image_picker.dart'; // Selecionar imagens da galeria
import 'package:firebase_storage/firebase_storage.dart'; // Armazenamento de imagens no Firebase

// Tela principal do chat
class ChatPage extends StatefulWidget {
  final String proposta; // Título ou descrição da proposta negociada
  final String outroUsuarioUid; // UID (identificador único) do outro usuário no chat

  const ChatPage({
    super.key,
    required this.proposta,
    required this.outroUsuarioUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// Estado da tela de chat
class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance; // Instância de autenticação
  final _db = FirebaseFirestore.instance; // Instância do banco de dados
  final _messageController = TextEditingController(); // Controlador da caixa de texto
  late final String _chatId; // ID único do chat entre os dois usuários
  final ImagePicker _picker = ImagePicker(); // Para escolher imagens
  String? _ultimoIdNotificado; // Armazena o ID da última mensagem notificada

  @override
  void initState() {
    super.initState();
    _chatId = _gerarChatId(_auth.currentUser!.uid, widget.outroUsuarioUid); // Gera ID único do chat
    setCurrentOpenChatId(_chatId); // Marca que o usuário está com esse chat aberto
    _marcarMensagensComoLidas(); // Marca mensagens como lidas ao abrir o chat
  }

  @override
  void dispose() {
    setCurrentOpenChatId(null); // Quando sai do chat, remove a marcação de chat aberto
    _messageController.dispose(); // Libera recursos do campo de texto
    super.dispose();
  }

  // Função para enviar uma mensagem (com ou sem imagem)
  Future<void> _enviarMensagem({String? imageUrl}) async {
    if (_messageController.text.isEmpty && imageUrl == null) return; // Ignora se estiver vazia

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Pequeno atraso por segurança
      await _db.collection('mensagens').add({
        'texto': _messageController.text, // Texto digitado
        'imagemUrl': imageUrl ?? '', // URL da imagem (se houver)
        'de': _auth.currentUser!.uid, // Quem está enviando
        'para': widget.outroUsuarioUid, // Quem vai receber
        'timestamp': FieldValue.serverTimestamp(), // Data/hora do servidor
        'chatId': _chatId, // ID único deste chat
        'proposta': widget.proposta, // Relaciona com a proposta
        'lidasPor': [_auth.currentUser!.uid], // Quem já leu (quem enviou)
      });

      _messageController.clear(); // Limpa a caixa de texto
      _marcarMensagensComoLidas(); // Marca como lida
    } catch (e) {
      // Exibe erro na tela, se ocorrer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: ${e.toString()}')),
      );
    }
  }

  // Seleciona uma imagem da galeria e envia no chat
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser!.uid}.jpg';
        final ref = FirebaseStorage.instance.ref().child('chat_images').child(fileName);
        await ref.putFile(file); // Faz o upload
        final imageUrl = await ref.getDownloadURL(); // Pega o link da imagem
        await _enviarMensagem(imageUrl: imageUrl); // Envia a mensagem com a imagem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem enviada!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e')),
        );
      }
    }
  }

  // Mostra notificação local no celular do usuário
  void _mostrarNotificacaoLocal(String titulo, String corpo) {
    flutterLocalNotificationsPlugin.show(
      0,
      titulo,
      corpo,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel', // Canal definido para notificações do chat
          'Chat',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Gera um ID único para o chat entre dois usuários
  String _gerarChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort(); // Ordena para sempre dar o mesmo resultado
    return ids.join('_'); // Ex: "abc_zyx"
  }

  // Marca como lidas todas as mensagens que ainda não foram marcadas
  Future<void> _marcarMensagensComoLidas() async {
    final meuUid = _auth.currentUser!.uid;
    final snap = await _db
        .collection('mensagens')
        .where('chatId', isEqualTo: _chatId)
        .get();

    for (var doc in snap.docs) {
      final lidasPor = List<String>.from(doc['lidasPor'] ?? []);
      if (!lidasPor.contains(meuUid)) {
        await doc.reference.update({
          'lidasPor': FieldValue.arrayUnion([meuUid])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meuUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.proposta}'), // Título do AppBar
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('mensagens')
                  .where('chatId', isEqualTo: _chatId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(), // Observa mensagens em tempo real
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

                // Se ainda não há mensagens
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nEnvie a primeira mensagem!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Verifica se deve exibir uma notificação local
                final ultimaMsg = messages.last;
                final isMinhaMsg = ultimaMsg['de'] == meuUid;
                final chatIdMsg = ultimaMsg['chatId'];
                final msgId = ultimaMsg.id;

                if (!isMinhaMsg &&
                    getCurrentOpenChatId() != chatIdMsg &&
                    _ultimoIdNotificado != msgId) {
                  _mostrarNotificacaoLocal(
                    'Nova mensagem em ${widget.proposta}',
                    ultimaMsg['texto'] ?? 'Você recebeu uma nova mensagem!',
                  );
                  _ultimoIdNotificado = msgId; // Marca como notificada
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isEu = msg['de'] == meuUid;
                    final timestamp = msg['timestamp'] as Timestamp?;
                    final data = msg.data() as Map<String, dynamic>;
                    final imageUrl = data.containsKey('imagemUrl') ? data['imagemUrl'] ?? '' : '';

                    return Align(
                      alignment: isEu ? Alignment.centerRight : Alignment.centerLeft,
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
                            // Exibe imagem se houver
                            if (imageUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Image.network(imageUrl, height: 120),
                              ),
                            // Exibe texto da mensagem se não estiver vazio
                            if ((msg['texto'] as String).isNotEmpty)
                              Text(msg['texto']),
                            // Exibe horário da mensagem
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
          // Campo de digitação e envio de mensagem
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Botão para enviar imagem
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.blue),
                  onPressed: _pickAndUploadImage,
                ),
                // Campo de texto para digitar mensagem
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
                // Botão de envio
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

  // Formata a data/hora da mensagem para exibição
  String _formatarData(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm - dd/MM').format(date);
  }
}
