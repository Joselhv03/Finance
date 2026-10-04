import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import 'login.dart';
import 'main_navigation.dart';

//
// Usamos un StreamBuilder (no solo un if una vez) porque
// onAuthStateChange también avisa si la sesión cambia DESPUÉS del
// arranque (ej. si el token expira y no se puede refrescar) — así
// la app reacciona sola sin que tengamos que revisarlo a mano.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras se resuelve el primer evento (restaurar la sesión
        // guardada toma un instante), mostramos un loading simple en
        // vez de parpadear hacia el login por error.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.ink,
            body: Center(child: CircularProgressIndicator(color: AppColors.usd)),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;
        return session != null ? const MainNavigation() : const LoginScreen();
      },
    );
  }
}