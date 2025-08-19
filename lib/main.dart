import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'formulario_page.dart';
import 'suministro_form_page.dart'; // importa tu nuevo formulario

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Formulario con Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // ruta inicial
      routes: {
        '/': (_) => const FormularioPage(), // tu formulario actual
        '/suministro': (_) => const SuministroFormPage(), // formulario de suministros
      },
    );
  }
}
