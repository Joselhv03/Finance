import 'package:supabase_flutter/supabase_flutter.dart';

// Esta clase es la única que "sabe" cómo hablar con Supabase Auth

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': username},
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Útil para saber, en cualquier pantalla, si ya hay una sesión activa.
  User? get currentUser => _client.auth.currentUser;
}