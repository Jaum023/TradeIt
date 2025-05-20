import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeit_app/src/features/ads/presentation/controllers/ad_controller.dart';

class CreateAdsPage extends ConsumerStatefulWidget {
  const CreateAdsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateAdsPage> createState() => _CreateAdsPageState();
}

class _CreateAdsPageState extends ConsumerState<CreateAdsPage> {
  String? selectedCondition;
  String? selectedCategory;

  final List<String> conditions = [
    'Novo',
    'Usado - Perfeitas Condições',
    'Usado - Bom',
    'Usado - Aceitável',
  ];

  final List<String> categories = [
    'Eletrônicos',
    'Roupas',
    'Móveis',
    'Livros',
    'Outros',
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAd() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final condition = selectedCondition ?? 'Novo';
    final category = selectedCategory ?? 'Outros';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar autenticado')),
      );
      return;
    }

    try {
      await ref.read(adControllerProvider).createAdWithExtras(
            title: title,
            description: description,
            ownerId: user.uid,
            category: category,
            condition: condition,
            imageUrl: null, // Adicionar upload no futuro
          );

      Navigator.of(context).pop(); // voltar após salvar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar anúncio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5FF),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Text(
                'Detalhes do Anúncio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Ação futura: selecionar imagem
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color(0xFFEDE7F6),
                  ),
                  child: const Center(
                    child: Text(
                      'Clique para adicionar uma imagem',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCondition,
                items: conditions
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(
                            condition,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCondition = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Condição',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                dropdownColor: Colors.white,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                dropdownColor: Colors.white,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Salvar Anúncio',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}