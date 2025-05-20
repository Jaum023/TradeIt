import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<void> createAd(AdEntity ad);
}