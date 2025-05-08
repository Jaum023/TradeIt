import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/register_page.dart';
import 'package:tradeit_app/src/features/home/presentation/pages/listing_page.dart';
import 'package:tradeit_app/src/features/ads/presentation/pages/create_ads_page.dart';

final routes = <String, WidgetBuilder>{
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/home': (context) => ListingPage(),
  '/create': (context) => CreateAdsPage(),
};