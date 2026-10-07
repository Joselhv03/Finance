import 'package:flutter/foundation.dart';
import '../Models/user_profile.dart';
import '../services/supabase_service.dart';

class ProfileController extends ChangeNotifier {
  final _authService = SupabaseService();

  UserProfile? profile;
  bool loading = false;
  String? errorMessage;

  void loadProfile() {
    profile = _authService.getCurrentProfile();
    notifyListeners();
  }

  Future<bool> updateUsername(String newUsername) async {
    return _runAction(() async {
      await _authService.updateUsername(newUsername);
      loadProfile(); // refresca el profile con el nuevo username
    });
  }

  Future<bool> updatePassword(String newPassword) async {
    return _runAction(() => _authService.updatePassword(newPassword));
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
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
}