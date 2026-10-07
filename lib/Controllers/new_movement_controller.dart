import 'package:flutter/foundation.dart';
import '../Models/income_bs.dart';
import '../Models/income_dollars.dart';
import '../Models/buy.dart';
import '../Models/movement.dart';
import '../Models/spent.dart';
import '../Models/account.dart';
import '../services/supabase_service.dart';
import 'app_refresh_signal.dart';

class NewMovementController extends ChangeNotifier {
  final _service = SupabaseService();

  bool loading = false;
  String? errorMessage;

  // Cuentas reales del usuario, para el selector de Ahorro/Egreso.
  List<Account> accounts = [];
  bool accountsLoading = false;

  Future<void> loadAccounts() async {
    accountsLoading = true;
    notifyListeners();
    try {
      accounts = await _service.fetchAccounts();
    } catch (_) {
    } finally {
      accountsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitIncomeBs(IncomeBs income) async {
    return _runAction(() => _service.createIncomeBs(income));
  }

  Future<bool> submitIncomeDollars(IncomeDollars income) async {
    return _runAction(() => _service.createIncomeDollars(income));
  }

  Future<bool> submitBuy(Buy buy) async {
    return _runAction(() => _service.createBuy(buy));
  }

  Future<bool> submitMovement(Movement movement) async {
    return _runAction(() => _service.createMovement(movement));
  }

  Future<bool> submitSpent(Spent spent) async {
    return _runAction(() => _service.createSpent(spent));
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      loading = false;
      notifyListeners();
      // Avisa a cualquier pantalla escuchando que hay datos nuevos que recargar.
      AppRefreshSignal.instance.notifyMovementSaved();
      return true;
    } catch (e) {
      loading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}