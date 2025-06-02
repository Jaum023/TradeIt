import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDatasource datasource;

  FavoriteRepositoryImpl(this.datasource);

  @override
  Future<bool> isFavorited(String userId, String adId) {
    return datasource.isFavorited(userId, adId);
  }

  @override
  Future<void> toggleFavorite(String userId, String adId) {
    return datasource.toggleFavorite(userId, adId);
  }

  @override
  Future<List<String>> getUserFavoriteAdIds(String userId) {
    return datasource.getUserFavoriteAdIds(userId);
  }
}