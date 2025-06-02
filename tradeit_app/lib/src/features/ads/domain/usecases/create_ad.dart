import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class CreateAd {
  final AdRepository repository;

  CreateAd(this.repository);

  Future<void> call(AdEntity ad) {
    final adWithLowercase = AdEntity(
      id: ad.id,
      title: ad.title,
      titleLowercase: ad.title.toLowerCase(),
      description: ad.description,
      category: ad.category,
      condition: ad.condition,
      imageUrl: ad.imageUrl,
      ownerId: ad.ownerId,
      createdAt: ad.createdAt,
      userName: ad.userName,
    );

    return repository.createAd(adWithLowercase);
  }
}