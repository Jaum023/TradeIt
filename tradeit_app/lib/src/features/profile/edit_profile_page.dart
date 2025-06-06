import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tradeit_app/shared/cloudinary_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeit_app/shared/globalUser.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  String? photoUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    photoUrl = currentUser?.photoUrl; 
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('Usuário autenticado: $user');
      if (user == null) {
        setState(() => isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado!')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      await user.updateDisplayName(nameController.text.trim());
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      currentUser = AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: doc['name'],
        photoUrl: doc['photoUrl'],
      );

      setState(() => isUploading = false);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar perfil: $e')),
      );
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => isUploading = true);
      String? url;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        url = await CloudinaryHelper.uploadImage(bytes);
      } else {
        url = await CloudinaryHelper.uploadImage(File(picked.path));
      }
      setState(() => isUploading = false);
      if (url != null) {
        setState(() {
          photoUrl = url;
        });
        // TODO: Salvar a URL no backend/Firebase ao salvar o perfil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao enviar imagem.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                    child: photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isUploading ? null : _pickAndUploadProfileImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.initialEmail,
              decoration: const InputDecoration(labelText: 'E-mail'),
              readOnly: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}