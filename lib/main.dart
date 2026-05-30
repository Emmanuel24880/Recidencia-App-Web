import 'package:app_web_1/firebase_options.dart';
import 'package:app_web_1/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  

  runApp(const MainApp());
  try {
    await FirebaseFirestore.instance.collection('debug').doc('test').set({
      'conexion': true,
    });
    print('🔥 CONECTADO A FIRESTORE');
  } catch (e) {
    print('❌ ERROR CONEXION: $e');
  }
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Honorata App Web',
    );
  }

  
}
