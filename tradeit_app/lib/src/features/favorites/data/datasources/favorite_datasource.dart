abstract class FavoriteDatasource {
  Future<bool> isFavorited(String userId, String adId);
  Future<void> toggleFavorite(String userId, String adId);
  Future<List<String>> getUserFavoriteAdIds(String userId);
}