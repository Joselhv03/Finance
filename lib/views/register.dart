import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import '../widgets/ledger_field.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = SupabaseService();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
            style: GoogleFonts.ibmPlexSans(),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return; // corta la función aquí, no sigue al loading
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _userNameController.text.trim(),
      );
      
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear cuenta',
                  style: GoogleFonts.newsreader(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Regístrate para empezar a llevar tu ahorro',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 40),

                LedgerField(
                  label: 'Nombre de usuario',
                  controller: _userNameController,
                ),
                const SizedBox(height: 22),

                LedgerField(
                  label: 'Correo',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 22),

                LedgerField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textDim,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 22),

                LedgerField(
                  label: 'Confirmar contraseña',
                  controller: _confirmPasswordController,
                  // Reutiliza el mismo booleano: si el usuario destapa
                  // una, tiene sentido que se destapen las dos.
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.usd,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : Text(
                            'Crear cuenta',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () {
                      // Vuelve a la pantalla anterior (login), que ya
                      // está en la pila de navegación.
                      Navigator.pop(context);
                    },
                    child: Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: AppColors.textDim,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}