import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<void> createAd(AdEntity ad);
  Future<void> updateAd(AdEntity ad);
}