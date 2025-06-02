import '../repositories/favorite_repository.dart';

class GetUserFavorites {
  final FavoriteRepository repository;

  GetUserFavorites(this.repository);

  Future<List<String>> call(String userId) {
    return repository.getUserFavoriteAdIds(userId);
  }
}