import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import 'login.dart';
import 'main_navigation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {

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