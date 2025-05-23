import 'package:flutter/material.dart';

class EditAdsPage extends StatefulWidget {
  const EditAdsPage({Key? key, required String condition, required String description, required String title, required String categories}) : super(key: key);

  @override
  _EditAdsPageState createState() => _EditAdsPageState();
}

class _EditAdsPageState extends State<EditAdsPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    titleController = TextEditingController(text: args['title']);
    descriptionController = TextEditingController(text: args['description']);
    selectedCondition = args['condition'];
    selectedCategory = args['category'];
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5FF),
        padding: const EdgeInsets.all(16.0),
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
              'Editar Anúncio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // selecionar uma imagem
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
              onPressed: () {
                // Ação ao salvar o anúncio editado
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.deepPurple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Salvar Alterações',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}