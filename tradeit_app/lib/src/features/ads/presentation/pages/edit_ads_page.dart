import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/ads/presentation/controllers/ad_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tradeit_app/shared/cloudinary_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EditAdsPage extends StatefulWidget {
  const EditAdsPage({Key? key, required String condition, required String description, required String title, required String categories}) : super(key: key);

  @override
  _EditAdsPageState createState() => _EditAdsPageState();
}

class _EditAdsPageState extends State<EditAdsPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  String? selectedCondition;
  String? selectedCategory;
  List<String> imageUrls = [];
  bool isUploading = false;

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
    final data = args['dataProduct'] as Map<String, dynamic>;

    titleController = TextEditingController(text: data['title']);
    descriptionController = TextEditingController(text: data['description']);
    selectedCondition = data['condition'];
    selectedCategory = data['category'];
    imageUrls = List<String>.from(data['imageUrls'] ?? []);
    locationController = TextEditingController(text: data['location'] ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
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
      if (url != null) {
        setState(() {
          imageUrls.add(url!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao enviar imagem.'))
        );
      }
      setState(() => isUploading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  void _saveAd() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final adId = args['adId'] as String;
    final data = args['dataProduct'] as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;

    final container = ProviderScope.containerOf(context);
    await container.read(adControllerProvider).updateAdWithExtras(
      id: adId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      ownerId: ownerId,
      category: selectedCategory ?? 'Outros',
      condition: selectedCondition ?? 'Novo',
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
      imageUrls: imageUrls,
      location: locationController.text.trim(),
    );

    Navigator.of(context).pop();
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
                'Editar Anúncio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index < imageUrls.length) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrls[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return GestureDetector(
                        onTap: isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(8.0),
                            color: const Color(0xFFEDE7F6),
                          ),
                          child: isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : const Icon(Icons.add_a_photo, color: Colors.deepPurple),
                        ),
                      );
                    }
                  },
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
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Localização',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: () async {
                      try {
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ative a localização no dispositivo.')),
                          );
                          return;
                        }
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Permissão de localização negada.')),
                            );
                            return;
                          }
                        }
                        if (permission == LocationPermission.deniedForever) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Permissão de localização permanentemente negada. Vá nas configurações do aparelho para liberar.')),
                          );
                          return;
                        }

                        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                        if (kIsWeb) {
                          locationController.text = "Lat: ${pos.latitude.toStringAsFixed(5)}, Lon: ${pos.longitude.toStringAsFixed(5)}";
                        } else {
                          List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
                          if (placemarks.isNotEmpty) {
                            final place = placemarks.first;
                            final cidade = (place.locality != null && place.locality!.isNotEmpty)
                                ? place.locality
                                : (place.subAdministrativeArea ?? '');
                            final estado = place.administrativeArea ?? '';
                            locationController.text = "$cidade, $estado";
                          } else {
                            locationController.text = "Lat: ${pos.latitude.toStringAsFixed(5)}, Lon: ${pos.longitude.toStringAsFixed(5)}";
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao obter localização: $e')),
                        );
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Localização obrigatória';
                  }
                  return null;
                },
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
      ),
    );
  }
}