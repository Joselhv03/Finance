import 'package:flutter/foundation.dart';

class AppRefreshSignal extends ChangeNotifier {
  AppRefreshSignal._();
  static final instance = AppRefreshSignal._();

  void notifyMovementSaved() => notifyListeners();
}