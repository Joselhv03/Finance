import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/user_profile.dart';
import '../Models/account.dart';

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

  // ── Cuentas de ahorro ──────────────────────────────────────
  // Si tu tabla o columnas tienen mayúsculas distintas a estas
  // (ej. "Account" en vez de "account", o "user_ID" en vez de
  // "user_id"), ajusta los strings de abajo para que coincidan
  // EXACTAMENTE con lo que ves en el Table Editor de Supabase.

  Future<List<Account>> fetchAccounts() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('Account')
        .select()
        .eq('user_ID', userId)
        .order('id');

    return (response as List)
        .map((row) => Account.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Account> createAccount({
    required String name,
    required double initialAmount,
    required double? targetAmount,
    required Color color,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('No hay un usuario logueado');
    }

    final newAccount = Account(
      id: '', // se ignora al insertar; Supabase genera el id real
      name: name,
      total: initialAmount,
      targetAmount: targetAmount,
      color: color,
    );

    final response = await _client
        .from('Account')
        .insert({
          ...newAccount.toInsertJson(),
          'user_ID': userId,
        })
        .select()
        .single();

    return Account.fromJson(response);
  }

  Future<void> updateAccount(Account account) async {
    await _client
        .from('Account')
        .update(account.toInsertJson())
        .eq('id', account.id);
  }

  Future<void> deleteAccount(String accountId) async {
    await _client.from('Account').delete().eq('id', accountId);
  }
}