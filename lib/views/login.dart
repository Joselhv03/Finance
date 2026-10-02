import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../widgets/ledger_field.dart';
import 'register.dart';
import 'main_navigation.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────
// StatefulWidget vs StatelessWidget:
// - Un StatelessWidget se dibuja una vez y no cambia solo (ej. un ícono fijo).
// - Un StatefulWidget puede REDIBUJARSE cuando algo cambia (ej. el usuario
//   escribe en un campo, o togglea "mostrar contraseña").
// Como este login necesita recordar lo que el usuario escribe y si la
// contraseña está oculta o visible, necesita ser Stateful.
// ─────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseService();
 
  bool _obscurePassword = true;
  bool _loading = false;
 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _handleLogin() async {
  setState(() {
    _loading = true;
  });

  try {
    await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
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
 
  // build() es el método que describe QUÉ se dibuja en pantalla.
  // Flutter lo vuelve a llamar automáticamente cada vez que algo
  // cambia con setState(). Todo lo que ves en pantalla es un árbol
  // de widgets anidados dentro de este método.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold da la estructura base de una pantalla: fondo, y
      // espacio reservado para cosas como AppBar, si la tuvieras.
      backgroundColor: AppColors.ink,
      body: SafeArea(
        // SafeArea evita que el contenido quede debajo del notch,
        // la barra de estado, o el "island" del celular.
        child: Center(
          child: SingleChildScrollView(
            // Permite hacer scroll si el teclado tapa parte del
            // formulario en pantallas pequeñas.
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              // Column apila widgets verticalmente, uno debajo del otro.
              // mainAxisSize.min hace que ocupe solo el alto necesario,
              // en vez de forzar todo el alto de la pantalla.
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 22),
                _buildPasswordField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildFooterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finance',
          style: GoogleFonts.newsreader(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
 
  Widget _buildEmailField() {
    return LedgerField(
      label: 'Correo',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }
 
  Widget _buildPasswordField() {
    return LedgerField(
      label: 'Contraseña',
      controller: _passwordController,
      obscureText: _obscurePassword,
      suffix: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textDim,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }
 
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleLogin,
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
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
              )
            : Text(
                'Iniciar sesión',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
 
  Widget _buildFooterLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
        },
        child: Text(
          '¿No tienes cuenta? Crear una',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            color: AppColors.textDim,
          ),
        ),
      ),
    );
  }
}