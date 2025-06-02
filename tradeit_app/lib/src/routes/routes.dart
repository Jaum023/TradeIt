import 'package:flutter/material.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:tradeit_app/src/features/auth/presentation/pages/register_page.dart';
import 'package:tradeit_app/src/features/home/presentation/pages/listing_page.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/pages/product_detail.dart';
import 'package:tradeit_app/src/features/ads/presentation/pages/create_ads_page.dart';
import 'package:tradeit_app/src/features/chat/presentation/pages/chat_page.dart';
import 'package:tradeit_app/src/features/chat/presentation/pages/inbox_page.dart';
import 'package:tradeit_app/src/features/chat/domain/entities/chat_message.dart' as domain;
import 'package:tradeit_app/src/features/ads/presentation/pages/edit_ads_page.dart';
import 'package:tradeit_app/src/features/profile/profile_page.dart';

final routes = <String, WidgetBuilder>{
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/home': (context) => ListingPage(),
  '/create': (context) => CreateAdsPage(),
  '/edit': (context) => const EditAdsPage(
        title: '', 
        description: '',
        condition: '',
        categories: '',
      ),
  '/details': (context) => ProductDetail(),
  '/profile': (context) => ProfilePage(),
  '/chat_teste': (context) => ChatPage(
    proposta: 'Trocar tênis por livro - 01/05',
    usuario: 'João da Feira',
  //    mensagensIniciais: [
  //      domain.ChatMessage(
  //        text: 'Olá! Esse tênis ainda está disponível?',
  //        isMe: true,
  //        time: 'ONTEM',
  //        sender: 'Você',
  //      ),
  //      domain.ChatMessage(
  //        text: 'Sim, está sim!',
  //        isMe: false,
  //        time: 'ONTEM',
  //        sender: 'João da Feira',
  //      ),
  //    ],
   ),
  '/inbox': (context) => InboxPage(),
};