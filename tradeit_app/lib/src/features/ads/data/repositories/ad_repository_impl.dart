import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

class AdRepositoryImpl implements AdRepository {
  final FirebaseFirestore firestore;

  AdRepositoryImpl(this.firestore);

  @override
  Future<void> createAd(AdEntity ad) async {
    await firestore.collection('ads').doc(ad.id).set({
      'title': ad.title,
      'titleLowercase': ad.title.toLowerCase(),
      'description': ad.description,
      'category': ad.category,
      'condition': ad.condition,
      'imageUrl': ad.imageUrl,
      'imageUrls': ad.imageUrls, 
      'ownerId': ad.ownerId,
      'createdAt': ad.createdAt.toIso8601String(),
      'userName': ad.userName,
      'location': ad.location, 
    });
  }

  @override
  Future<void> updateAd(AdEntity ad) async {
    final docRef = firestore.collection('ads').doc(ad.id);

    await docRef.update({
      'title': ad.title,
      'titleLowercase': ad.title.toLowerCase(),
      'description': ad.description,
      'category': ad.category,
      'condition': ad.condition,
      'imageUrl': ad.imageUrl,
      'imageUrls': ad.imageUrls, 
      'location': ad.location, 
    });
  }
}