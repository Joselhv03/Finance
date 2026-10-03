import 'package:flutter/foundation.dart';
import '../Models/income_bs.dart';
import "../services/supabase_service.dart";

class NewMovementController extends ChangeNotifier {
  final _service = SupabaseService();

  bool loading = false;
  String? errorMessage;

  Future<bool> submitIncomeBs(IncomeBs income) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.createIncomeBs(income);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Los demás tipos (Compra, Ahorro, Egreso) se agregan aquí mismo
  // más adelante, siguiendo este mismo patrón.
}