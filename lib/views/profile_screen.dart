import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../services/supabase_service.dart';
import 'login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = SupabaseService();
    final user = authService.currentUser;
    final displayName = user?.userMetadata?['display_name'] as String?;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text(
                'Perfil',
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Usuario',
                style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
              ),
              const SizedBox(height: 6),
              Text(
                displayName ?? '—',
                style: GoogleFonts.newsreader(fontSize: 18, color: AppColors.text),
              ),
              const SizedBox(height: 18),
              Text(
                'Correo',
                style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? '—',
                style: GoogleFonts.newsreader(fontSize: 18, color: AppColors.text),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      // pushAndRemoveUntil borra TODA la pila de
                      // navegación (resumen, cuentas, etc.), no solo
                      // la pantalla actual — así no queda nada del
                      // usuario anterior al volver al login.
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}