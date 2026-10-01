import 'package:flutter/foundation.dart';
import '../Models/user_profile.dart';
import '../services/supabase_service.dart';

// ChangeNotifier es la clase base de Flutter para "algo que puede
// avisar cuando cambió". Cuando llamamos notifyListeners(), todas
// las pantallas que estén "escuchando" este controller (con
// Provider, como vamos a ver en profile_screen.dart) se redibujan
// solas — así la vista nunca llama a setState() directamente para
// estos datos, solo reacciona a lo que el controller le informa.
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

  // Pequeño helper para no repetir el mismo try/catch/loading en
  // cada método. Devuelve true si la acción tuvo éxito, false si
  // falló (y deja el mensaje en errorMessage para que la vista lo
  // muestre).
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