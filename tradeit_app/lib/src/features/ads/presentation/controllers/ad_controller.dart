import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradeit_app/src/features/ads/domain/entities/ad_entity.dart';
import 'package:tradeit_app/src/features/ads/domain/usecases/create_ad.dart';
import 'package:tradeit_app/src/features/ads/domain/usecases/update_ad.dart';
import 'package:uuid/uuid.dart';
import 'ad_providers.dart';

final adControllerProvider = Provider((ref) {
  final create = ref.read(createAdProvider);
  final update = ref.read(updateAdProvider);
  return AdController(create, update);
});

class AdController {
  final CreateAd createAd;
  final UpdateAd updateAd;

  AdController(this.createAd, this.updateAd);

  Future<void> createAdWithExtras({
    required String title,
    required String description,
    required String ownerId,
    required String category,
    required String condition,
    String? imageUrl,
    required List<String> imageUrls, 
    String? userName = '',
    String? location,
  }) async {
    final ad = AdEntity(
      id: const Uuid().v4(),
      title: title,
      titleLowercase: title.toLowerCase(),
      description: description,
      category: category,
      condition: condition,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      ownerId: ownerId,
      createdAt: DateTime.now(),
      userName: userName ?? '',
      location: location,
    );

    await createAd(ad);
  }

  Future<void> updateAdWithExtras({
    required String id,
    required String title,
    required String description,
    required String ownerId,
    required String category,
    required String condition,
    String? imageUrl,
    required List<String> imageUrls, 
    String? userName = '',
    String? location,
  }) async {
    final updatedAd = AdEntity(
      id: id,
      title: title,
      titleLowercase: title.toLowerCase(),
      description: description,
      category: category,
      condition: condition,
      imageUrl: imageUrl,
      imageUrls: imageUrls, 
      ownerId: ownerId,
      createdAt: DateTime.now(),
      userName: userName ?? '',
      location: location,
    );

    await updateAd(updatedAd);
  }
}