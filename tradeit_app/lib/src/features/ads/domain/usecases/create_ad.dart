import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class CreateAd {
  final AdRepository repository;

  CreateAd(this.repository);

  Future<void> call(AdEntity ad) {
    return repository.createAd(ad);
  }
}