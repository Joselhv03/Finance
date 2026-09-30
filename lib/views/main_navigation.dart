import 'package:flutter/material.dart';
import 'resumen_screen.dart';
import 'accounts_screen.dart';
import 'months_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

// Esta es la pantalla "raíz" después del login: siempre visible
// será la barra inferior, y arriba cambia el contenido según la
// pestaña seleccionada.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // El orden aquí debe coincidir exactamente con el orden de los
  // íconos en bottom_nav_bar.dart.
  final _screens = const [
    ResumenScreen(),
    AccountsScreen(),
    MonthsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene TODAS las pantallas construidas al
      // mismo tiempo, solo mostrando la seleccionada y ocultando el
      // resto. La diferencia con solo cambiar de widget: si entras a
      // "Cuentas", expandes una tarjeta, y vuelves a "Home", al
      // regresar a "Cuentas" la tarjeta sigue expandida — el estado
      // de cada pestaña no se pierde al cambiar entre ellas.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}