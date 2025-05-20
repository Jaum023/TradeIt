import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradeit_app/src/features/ads/domain/entities/ad_entity.dart';
import 'package:tradeit_app/src/features/ads/domain/usecases/create_ad.dart';
import 'package:uuid/uuid.dart';
import 'ad_providers.dart';

final adControllerProvider = Provider((ref) {
  final usecase = ref.read(createAdProvider);
  return AdController(usecase);
});

class AdController {
  final CreateAd createAd;

  AdController(this.createAd);

  Future<void> createAdWithExtras({
    required String title,
    required String description,
    required String ownerId,
    required String category,
    required String condition,
    String? imageUrl, // agora é opcional
  }) async {
    final ad = AdEntity(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      condition: condition,
      imageUrl: imageUrl,
      ownerId: ownerId,
      createdAt: DateTime.now(),
    );

    await createAd(ad);
  }
}