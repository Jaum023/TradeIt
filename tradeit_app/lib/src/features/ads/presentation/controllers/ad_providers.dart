import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/ad_repository_impl.dart';
import '../../domain/usecases/create_ad.dart';
import '../../domain/usecases/update_ad.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final adRepositoryProvider = Provider(
  (ref) => AdRepositoryImpl(ref.read(firestoreProvider)),
);

final createAdProvider = Provider(
  (ref) => CreateAd(ref.read(adRepositoryProvider)),
);

final updateAdProvider = Provider((ref) {
  final repo = ref.read(adRepositoryProvider);
  return UpdateAd(repo);
});