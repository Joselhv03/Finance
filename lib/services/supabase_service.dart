import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/user_profile.dart';

// Esta clase es la única parte de tu app que "sabe" cómo hablar con
// Supabase Auth. Tus pantallas (login.dart, register.dart) solo van
// a llamar a estos métodos, sin saber nada de los detalles de
// Supabase. Si mañana cambias de backend, solo tocas este archivo.
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
      // "data" guarda metadata personalizada junto al usuario.
      // Usamos la key "display_name" porque es la que el dashboard
      // de Supabase busca automáticamente para mostrarla en la
      // columna "Display Name" de Authentication > Users.
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

  // Lee los datos actuales del usuario logueado y los devuelve ya
  // como UserProfile (el Model), no como el tipo crudo de Supabase.
  // Esto es justo la frontera entre Service y Model: aquí es donde
  // se "traduce" la respuesta de Supabase a tu propia forma de datos.
  UserProfile getCurrentProfile() {
    final user = _client.auth.currentUser;
    return UserProfile(
      email: user?.email ?? '',
      username: user?.userMetadata?['display_name'] as String? ?? '',
    );
  }

  Future<void> updateUsername(String newUsername) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'display_name': newUsername}),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}