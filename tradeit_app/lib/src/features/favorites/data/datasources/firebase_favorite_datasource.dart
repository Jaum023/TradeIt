import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_datasource.dart';

class FirebaseFavoriteDatasource implements FavoriteDatasource {
  final FirebaseFirestore firestore;

  FirebaseFavoriteDatasource(this.firestore);

  @override
  Future<bool> isFavorited(String userId, String adId) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(adId)
        .get();
    return doc.exists;
  }

  @override
  Future<void> toggleFavorite(String userId, String adId) async {
    final ref = firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(adId);

    final exists = (await ref.get()).exists;

    if (exists) {
      await ref.delete();
    } else {
      await ref.set({'timestamp': FieldValue.serverTimestamp()});
    }
  }

  @override
  Future<List<String>> getUserFavoriteAdIds(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}