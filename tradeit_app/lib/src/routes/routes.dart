import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/register_page.dart';
import 'package:tradeit_app/src/features/home/presentation/pages/listing_page.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/pages/product_detail.dart';
import 'package:tradeit_app/src/features/ads/presentation/pages/create_ads_page.dart';
import 'package:tradeit_app/src/features/chat/presentation/pages/chat_page.dart';
import 'package:tradeit_app/src/features/chat/presentation/pages/inbox_page.dart';
import 'package:tradeit_app/src/features/ads/presentation/pages/edit_ads_page.dart';
import 'package:tradeit_app/src/features/profile/profile_page.dart';
import 'package:tradeit_app/src/features/favorites/presentation/pages/favorites_page.dart';

final routes = <String, WidgetBuilder>{
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => ListingPage(),
  '/create': (context) => const CreateAdsPage(),
  '/edit':
      (context) => const EditAdsPage(
        title: '',
        description: '',
        condition: '',
        categories: '',
      ),
  '/details': (context) => ProductDetail(),
  '/profile': (context) => const ProfilePage(),
  '/chat': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};

    return ChatPage(
      proposta: args['proposta'] ?? 'Nova proposta',
      outroUsuarioUid: args['outroUsuarioUid'] ?? '',
    );
  },
  '/inbox': (context) => const InboxPage(),
  '/favorites': (context) => const FavoritesPage(),
};
