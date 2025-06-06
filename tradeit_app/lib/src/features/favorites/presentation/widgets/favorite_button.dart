import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/shared/globalUser.dart';

class FavoriteButton extends StatefulWidget {
  final String adId;

  const FavoriteButton({super.key, required this.adId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.id)
        .collection('favorites')
        .doc(widget.adId);

    final doc = await ref.get();
    if (mounted) {
      setState(() {
        isFavorited = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.id)
        .collection('favorites')
        .doc(widget.adId);

    final exists = (await ref.get()).exists;
    if (exists) {
      await ref.delete();
    } else {
      await ref.set({'timestamp': FieldValue.serverTimestamp()});
    }

    if (mounted) {
      setState(() {
        isFavorited = !isFavorited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleFavorite,
    );
  }
}