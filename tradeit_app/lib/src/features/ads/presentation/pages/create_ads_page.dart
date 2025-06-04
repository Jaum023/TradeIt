import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeit_app/shared/globalUser.dart';
import 'package:tradeit_app/src/features/ads/presentation/controllers/ad_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tradeit_app/shared/cloudinary_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  final TextEditingController locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<String> imageUrls = [];
  bool isUploading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) return;

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
            imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
            imageUrls: imageUrls,
            userName: currentUser?.name,
            location: locationController.text.trim(),
          );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar anúncio: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5FF),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Título obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Descrição obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Localização',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.deepPurple),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione a condição';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione a categoria';
                    }
                    return null;
                  },
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
      ),
    );
  }
}