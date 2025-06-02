import '../repositories/favorite_repository.dart';

class ToggleFavorite {
  final FavoriteRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(String userId, String adId) {
    return repository.toggleFavorite(userId, adId);
  }
}