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
    // No hace falta actualizar Month.income_total/expense aquí: el
    // trigger trg_income_bs_affect_month se encarga solo apenas esta
    // fila se inserta.
  }

  Future<void> createIncomeDollars(IncomeDollars income) async {
    final monthId = await getOrCreateMonthId(income.date);

    await _client.from('Income_dollars').insert({
      ...income.toInsertJson(),
      'month_ID': monthId,
    });
    // El trigger de Income_dollars (que falta crear si todavía no lo
    // hicimos) debe sumar a Month.total_saving.
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

  // Busca el Month del usuario actual para ese año/mes, SIN crearlo
  // si no existe (a diferencia de getOrCreateMonthId). Devuelve null
  // cuando ese mes todavía no tiene ningún movimiento registrado.
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
}