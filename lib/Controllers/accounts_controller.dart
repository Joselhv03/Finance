import 'package:flutter/material.dart';
import '../Models/account.dart';
import '../services/supabase_service.dart';
import 'app_refresh_signal.dart';

class AccountsController extends ChangeNotifier {
  final _service = SupabaseService();

  List<Account> accounts = [];
  bool loading = false;
  String? errorMessage;

  AccountsController() {
    AppRefreshSignal.instance.addListener(_handleExternalRefresh);
  }

  @override
  void dispose() {
    AppRefreshSignal.instance.removeListener(_handleExternalRefresh);
    super.dispose();
  }

  void _handleExternalRefresh() => loadAccounts();

  Future<void> loadAccounts() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      accounts = await _service.fetchAccounts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount({
    required String name,
    required double initialAmount,
    required double? targetAmount,
    required Color color,
  }) async {
    return _runAction(() async {
      final created = await _service.createAccount(
        name: name,
        initialAmount: initialAmount,
        targetAmount: targetAmount,
        color: color,
      );
      accounts = [...accounts, created];
    });
  }

  Future<bool> updateAccount(Account updated) async {
    return _runAction(() async {
      await _service.updateAccount(updated);
      accounts = [
        for (final account in accounts)
          if (account.id == updated.id) updated else account,
      ];
    });
  }

  Future<bool> deleteAccount(String id) async {
    return _runAction(() async {
      await _service.deleteAccount(id);
      accounts = accounts.where((a) => a.id != id).toList();
    });
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    try {
      await action();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}