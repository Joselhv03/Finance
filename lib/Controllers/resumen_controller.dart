import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/supabase_service.dart';
import 'app_refresh_signal.dart';

class RecentMovementItem {
  final String description;
  final String amountText;
  final Color color;
  final DateTime date;

  RecentMovementItem({
    required this.description,
    required this.amountText,
    required this.color,
    required this.date,
  });
}

class ResumenController extends ChangeNotifier {
  final _service = SupabaseService();

  bool loading = false;
  String? errorMessage;

  double incomeTotal = 0;
  double totalSaving = 0;
  double pendingToDistribute = 0;
  List<RecentMovementItem> recentMovements = [];

  ResumenController() {
    AppRefreshSignal.instance.addListener(_handleExternalRefresh);
  }

  @override
  void dispose() {
    AppRefreshSignal.instance.removeListener(_handleExternalRefresh);
    super.dispose();
  }

  void _handleExternalRefresh() => loadCurrentMonth();

  Future<void> loadCurrentMonth() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final month = await _service.fetchMonth(now.year, now.month);

      pendingToDistribute = await _service.fetchTotalPendingToDistribute();

      if (month == null) {
        incomeTotal = 0;
        totalSaving = 0;
        recentMovements = [];
      } else {
        incomeTotal = month.incomeTotal;
        totalSaving = month.totalSaving;

        final results = await Future.wait([
          _service.fetchIncomeBsForMonth(month.id),
          _service.fetchIncomeDollarsForMonth(month.id),
          _service.fetchBuysForMonth(month.id),
          _service.fetchMovementsForMonth(month.id),
          _service.fetchSpentsForMonth(month.id),
          _service.fetchAccounts(),
        ]);

        final incomesBs = results[0] as List;
        final incomesDollars = results[1] as List;
        final buys = results[2] as List;
        final movements = results[3] as List;
        final spents = results[4] as List;
        final accounts = results[5] as List;

        final accountNames = {for (final a in accounts) a.id as String: a.name as String};

        final items = <RecentMovementItem>[
          for (final i in incomesBs)
            RecentMovementItem(
              description: i.concept,
              amountText: '${i.amount.toStringAsFixed(2)} Bs',
              color: AppColors.bs,
              date: i.date,
            ),
          for (final i in incomesDollars)
            RecentMovementItem(
              description: i.concept,
              amountText: '${i.amount.toStringAsFixed(2)} \$',
              color: AppColors.usd,
              date: i.date,
            ),
          for (final b in buys)
            RecentMovementItem(
              description: 'Compra · tasa ${b.rate.toStringAsFixed(0)}',
              amountText: '${b.dollarAmount.toStringAsFixed(2)} \$',
              color: AppColors.usd,
              date: b.date,
            ),
          for (final m in movements)
            RecentMovementItem(
              description: 'Ahorro · ${accountNames[m.accountId] ?? 'Cuenta'}',
              amountText: '${m.dollarAmount.toStringAsFixed(2)} \$',
              color: AppColors.usd,
              date: m.date,
            ),
          for (final s in spents)
            RecentMovementItem(
              description: '${s.description} · ${accountNames[s.accountId] ?? 'Cuenta'}',
              amountText: '${s.dollarAmount.toStringAsFixed(2)} \$',
              color: AppColors.danger,
              date: s.date,
            ),
        ];

        items.sort((a, b) => b.date.compareTo(a.date));
        recentMovements = items.take(4).toList();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}