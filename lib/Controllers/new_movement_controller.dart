import 'package:flutter/foundation.dart';
import '../Models/income_bs.dart';
import '../Models/income_dollars.dart';
import '../services/supabase_service.dart';
import 'app_refresh_signal.dart';

class NewMovementController extends ChangeNotifier {
  final _service = SupabaseService();

  bool loading = false;
  String? errorMessage;

  Future<bool> submitIncomeBs(IncomeBs income) async {
    return _runAction(() => _service.createIncomeBs(income));
  }

  Future<bool> submitIncomeDollars(IncomeDollars income) async {
    return _runAction(() => _service.createIncomeDollars(income));
  }

  // Los demás tipos (Compra, Ahorro, Egreso) se agregan aquí mismo
  // más adelante, siguiendo este mismo patrón.

  Future<bool> _runAction(Future<void> Function() action) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      loading = false;
      notifyListeners();
      // Avisa a cualquier pantalla escuchando (Meses, y más adelante
      // Resumen/Cuentas) que hay datos nuevos que recargar.
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