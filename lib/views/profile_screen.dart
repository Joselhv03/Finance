import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../Controller/profile_controller.dart';
import '../widgets/ledger_field.dart';
import '../services/supabase_service.dart';
import 'login.dart';

// ProfileScreen es solo el punto de entrada: crea el controller y
// lo pone disponible con Provider para todo lo que esté debajo.
// El widget que realmente dibuja la pantalla es _ProfileView.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    // context.watch hace que este widget se reconstruya automáticamente
    // cada vez que el controller llama a notifyListeners().
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;

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

              _buildField(
                label: 'Correo',
                value: profile?.email ?? '—',
              ),
              const SizedBox(height: 22),

              _buildField(
                label: 'Nombre de usuario',
                value: profile?.username ?? '—',
                onEdit: () => _showEditUsernameSheet(context, controller),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showChangePasswordSheet(context, controller),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.usd,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cambiar contraseña',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleSignOut(context),
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

  Widget _buildField({required String label, required String value, VoidCallback? onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.newsreader(fontSize: 18, color: AppColors.text),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textDim),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await SupabaseService().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showEditUsernameSheet(BuildContext context, ProfileController controller) {
    final nameController = TextEditingController(text: controller.profile?.username);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar nombre de usuario',
                style: GoogleFonts.newsreader(fontSize: 20, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              LedgerField(label: 'Nombre de usuario', controller: nameController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isEmpty) return;
                    final success = await controller.updateUsername(newName);
                    if (sheetContext.mounted && success) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.usd,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text('Guardar', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context, ProfileController controller) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cambiar contraseña',
                style: GoogleFonts.newsreader(fontSize: 20, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              LedgerField(
                label: 'Nueva contraseña',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 22),
              LedgerField(
                label: 'Confirmar contraseña',
                controller: confirmController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.length < 6) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'La contraseña debe tener al menos 6 caracteres',
                            style: GoogleFonts.ibmPlexSans(),
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    if (passwordController.text != confirmController.text) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Las contraseñas no coinciden',
                            style: GoogleFonts.ibmPlexSans(),
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    final success = await controller.updatePassword(passwordController.text);
                    if (sheetContext.mounted && success) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.usd,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text('Guardar', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}