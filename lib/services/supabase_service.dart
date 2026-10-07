import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/user_profile.dart';
import '../Models/account.dart';
import '../Models/income_bs.dart';
import '../Models/income_dollars.dart';
import '../Models/buy.dart';
import '../Models/movement.dart';
import '../Models/spent.dart';
import '../Models/month.dart';

// Esta clase es la única parte de la app que "sabe" cómo hablar con Supabase Auth.
//Si se cambia de backend, solo se toca este archivo.
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

  // ── Meses ──────────────────────────────────────────────────

  static const _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  String monthNameFor(DateTime date) => '${_monthNames[date.month - 1]} ${date.year}';

  // Busca el Month del usuario actual para la fecha dada; si no
  // existe, lo crea con los montos en 0 y devuelve su id. Cualquier
  // Controller que vaya a guardar un ingreso/compra/movimiento/egreso
  // llama esto PRIMERO para saber a qué month_id apuntar.
  Future<String> getOrCreateMonthId(DateTime date) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('No hay un usuario logueado');

    final name = monthNameFor(date);

    final existing = await _client
        .from('Month')
        .select('id')
        .eq('user_ID', userId)
        .eq('name', name)
        .maybeSingle();

    if (existing != null) {
      return existing['id'].toString();
    }

    final created = await _client
        .from('Month')
        .insert({
          'user_ID': userId,
          'name': name,
          'income_total': 0,
          'expense': 0,
          'total_saving': 0,
        })
        .select('id')
        .single();

    return created['id'].toString();
  }

  // ── Movimientos ────────────────────────────────────────────

  Future<void> createIncomeBs(IncomeBs income) async {
    final monthId = await getOrCreateMonthId(income.date);

    await _client.from('Income_bs').insert({
      ...income.toInsertJson(),
      'month_ID': monthId,
    });
  }

  Future<void> createIncomeDollars(IncomeDollars income) async {
    final monthId = await getOrCreateMonthId(income.date);

    await _client.from('Income_dollars').insert({
      ...income.toInsertJson(),
      'month_ID': monthId,
    });
  }

  Future<void> createBuy(Buy buy) async {
    final monthId = await getOrCreateMonthId(buy.date);

    await _client.from('Buy').insert({
      ...buy.toInsertJson(),
      'month_ID': monthId,
    });
    // trg_buy_affect_month suma a total_saving y resta de expense.
  }

  Future<void> createMovement(Movement movement) async {
    final monthId = await getOrCreateMonthId(movement.date);

    await _client.from('Movement').insert({
      ...movement.toInsertJson(),
      'month_ID': monthId,
    });
    // trg_movement_affect_account suma a Account.total.
  }

  Future<void> createSpent(Spent spent) async {
    final monthId = await getOrCreateMonthId(spent.date);

    await _client.from('Spent').insert({
      ...spent.toInsertJson(),
      'month_ID': monthId,
    });
    // trg_spent_affect_account resta de Account.total.
  }

  Future<Month?> fetchMonth(int year, int monthNumber) async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final name = monthNameFor(DateTime(year, monthNumber));

    final row = await _client
        .from('Month')
        .select()
        .eq('user_ID', userId)
        .eq('name', name)
        .maybeSingle();

    return row != null ? Month.fromJson(row) : null;
  }

  Future<double> fetchTotalPendingToDistribute() async {
    final monthsRows = await _client.from('Month').select('total_saving');
    final totalSaving = (monthsRows as List).fold<double>(
      0,
      (sum, m) => sum + ((m['total_saving'] as num?)?.toDouble() ?? 0),
    );
 
    final movementsRows = await _client.from('Movement').select('dollar_amount');
    final totalDistributed = (movementsRows as List).fold<double>(
      0,
      (sum, r) => sum + ((r['dollar_amount'] as num?)?.toDouble() ?? 0),
    );
 
    return totalSaving - totalDistributed;
  }
 
  Future<List<IncomeBs>> fetchIncomeBsForMonth(String monthId) async {
    final rows = await _client
        .from('Income_bs')
        .select()
        .eq('month_ID', monthId)
        .order('date');
    return (rows as List).map((r) => IncomeBs.fromJson(r)).toList();
  }
 
  Future<List<IncomeDollars>> fetchIncomeDollarsForMonth(String monthId) async {
    final rows = await _client
        .from('Income_dollars')
        .select()
        .eq('month_ID', monthId)
        .order('date');
    return (rows as List).map((r) => IncomeDollars.fromJson(r)).toList();
  }
 
  Future<List<Buy>> fetchBuysForMonth(String monthId) async {
    final rows = await _client
        .from('Buy')
        .select()
        .eq('month_ID', monthId)
        .order('date');
    return (rows as List).map((r) => Buy.fromJson(r)).toList();
  }
 
  Future<List<Movement>> fetchMovementsForMonth(String monthId) async {
    final rows = await _client
        .from('Movement')
        .select()
        .eq('month_ID', monthId)
        .order('date');
    return (rows as List).map((r) => Movement.fromJson(r)).toList();
  }
 
  Future<List<Spent>> fetchSpentsForMonth(String monthId) async {
    final rows = await _client
        .from('Spent')
        .select()
        .eq('month_ID', monthId)
        .order('date');
    return (rows as List).map((r) => Spent.fromJson(r)).toList();
  }
 
  // ── Borrado de movimientos ─────────────────────────────────
 
  Future<void> deleteIncomeBs(String id) async {
    await _client.from('Income_bs').delete().eq('id', id);
  }
 
  Future<void> deleteIncomeDollars(String id) async {
    await _client.from('Income_dollars').delete().eq('id', id);
  }
 
  Future<void> deleteBuy(String id) async {
    await _client.from('Buy').delete().eq('id', id);
  }
 
  Future<void> deleteMovement(String id) async {
    await _client.from('Movement').delete().eq('id', id);
  }
 
  Future<void> deleteSpent(String id) async {
    await _client.from('Spent').delete().eq('id', id);
  }
}