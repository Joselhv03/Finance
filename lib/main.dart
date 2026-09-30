import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env y deja sus valores disponibles globalmente a través de dotenv.env['NOMBRE_VARIABLE'].
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MainApp());
}

// Acceso rápido al cliente de Supabase desde cualquier parte de la
// app, sin tener que escribir Supabase.instance.client cada vez.
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}