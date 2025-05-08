import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/register_page.dart';
import 'package:tradeit_app/src/features/home/presentation/pages/listing_page.dart';
import 'package:tradeit_app/src/features/product_detail/product_detail.dart';

final routes = <String, WidgetBuilder>{
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/home': (context) => ListingPage(),
  '/details': (context) => ProductDetail()
};