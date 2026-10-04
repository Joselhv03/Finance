import 'package:flutter/foundation.dart';
import '../Models/month.dart';
import '../Models/income_bs.dart';
import '../Models/income_dollars.dart';
import '../Models/buy.dart';
import '../Models/movement.dart';
import '../Models/spent.dart';
import '../Models/account.dart';
import '../services/supabase_service.dart';
import 'app_refresh_signal.dart';

class MonthsController extends ChangeNotifier {
  final _service = SupabaseService();

  bool loading = false;
  String? errorMessage;

  Month? month; // null = este mes no tiene ningún movimiento todavía
  List<IncomeBs> incomesBs = [];
  List<IncomeDollars> incomesDollars = [];
  List<Buy> buys = [];
  List<Movement> movements = [];
  List<Spent> spents = [];

  // id de cuenta → nombre, para poder mostrar el nombre en vez del
  // id crudo en las filas de Movement/Spent.
  Map<String, String> accountNames = {};

  int? _lastYear;
  int? _lastMonthNumber;

  MonthsController() {
    // Cada vez que se guarda un movimiento en CUALQUIER pantalla,
    // recargamos el último mes que este controller tenía abierto.
    AppRefreshSignal.instance.addListener(_handleExternalRefresh);
  }

  @override
  void dispose() {
    AppRefreshSignal.instance.removeListener(_handleExternalRefresh);
    super.dispose();
  }

  void _handleExternalRefresh() {
    if (_lastYear != null && _lastMonthNumber != null) {
      loadMonth(_lastYear!, _lastMonthNumber!);
    }
  }

  Future<void> loadMonth(int year, int monthNumber) async {
    _lastYear = year;
    _lastMonthNumber = monthNumber;
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedMonth = await _service.fetchMonth(year, monthNumber);
      month = fetchedMonth;

      if (fetchedMonth == null) {
        // Mes vacío: no hace falta pedir movimientos que no existen.
        incomesBs = [];
        incomesDollars = [];
        buys = [];
        movements = [];
        spents = [];
      } else {
        final results = await Future.wait([
          _service.fetchIncomeBsForMonth(fetchedMonth.id),
          _service.fetchIncomeDollarsForMonth(fetchedMonth.id),
          _service.fetchBuysForMonth(fetchedMonth.id),
          _service.fetchMovementsForMonth(fetchedMonth.id),
          _service.fetchSpentsForMonth(fetchedMonth.id),
          _service.fetchAccounts(),
        ]);

        incomesBs = results[0] as List<IncomeBs>;
        incomesDollars = results[1] as List<IncomeDollars>;
        buys = results[2] as List<Buy>;
        movements = results[3] as List<Movement>;
        spents = results[4] as List<Spent>;

        final accounts = results[5] as List<Account>;
        accountNames = {for (final a in accounts) a.id: a.name};
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}