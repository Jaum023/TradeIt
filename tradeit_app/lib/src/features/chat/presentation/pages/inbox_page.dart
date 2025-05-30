import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';

class InboxPage extends StatelessWidget {
  InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Propostas", style: TextStyle(color: Colors.blue)),
        backgroundColor: const Color(0xFF1B202D),
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
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
            return const Center(child: Text('Nenhuma conversa ainda.', style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: propostas.length,
            itemBuilder: (context, index) {
              final proposta = propostas[index].data() as Map<String, dynamic>;
              final nomes = proposta['nomes'] as List<dynamic>;
              final outroNome = nomes.firstWhere(
                (n) => n != FirebaseAuth.instance.currentUser?.displayName,
                orElse: () => 'Outro usuário',
              );
              return _buildProposta(
                titulo: proposta['proposta'] ?? '',
                ultimaMensagem: proposta['ultimaMensagem'] ?? '',
                hora: proposta['timestamp'] != null && proposta['timestamp'] is Timestamp
                    ? DateFormat('HH:mm').format((proposta['timestamp'] as Timestamp).toDate())
                    : '',
                usuario: outroNome,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        proposta: proposta['proposta'],
                        usuario: outroNome,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 3),
    );
  }

  Widget _buildProposta({
    required String titulo,
    required String ultimaMensagem,
    required String hora,
    required String usuario,
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
            hora,
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