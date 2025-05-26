import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class UpdateAd {
  final AdRepository repository;

  UpdateAd(this.repository);

  Future<void> call(AdEntity ad) async {
    await repository.updateAd(ad);
  }
}