import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../widgets/expandable_account_card.dart';
import '../widgets/create_account_sheet.dart';
import '../widgets/edit_account_sheet.dart';

// Modelo simple en memoria para esta pantalla. Cuando conectemos
// Supabase, esto se reemplaza por tu modelo real de la tabla Account.
class _AccountItem {
  final String name;
  final double total;
  final double? target;
  final Color color;

  _AccountItem({
    required this.name,
    required this.total,
    required this.color,
    this.target,
  });
}

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  // Datos de ejemplo, igual que en resumen_screen.dart. Cuando
  // conectemos el backend, esto viene de una consulta a Account.
  final List<_AccountItem> _accounts = [
    _AccountItem(name: 'General', total: 240.00, color: AppColors.usd),
    _AccountItem(
      name: 'Viaje',
      total: 180.50,
      target: 600,
      color: accountColorPalette[3], // rosa
    ),
    _AccountItem(name: 'Casa', total: 610.00, color: AppColors.bs),
    _AccountItem(
      name: 'Emergencia',
      total: 95.00,
      target: 300,
      color: accountColorPalette[2], // menta
    ),
  ];

  Future<void> _handleCreateAccount() async {
    final result = await showCreateAccountSheet(context);
    if (result != null) {
      setState(() {
        _accounts.add(
          _AccountItem(
            name: result.name,
            total: result.initialAmount,
            target: result.targetAmount,
            color: result.color,
          ),
        );
      });
    }
  }

  // EditAccountData no trae 'total' (no se edita a mano), así que
  // reconstruimos el _AccountItem conservando el total que ya tenía.
  void _handleEditAccount(int index, EditAccountData data) {
    setState(() {
      _accounts[index] = _AccountItem(
        name: data.name,
        total: _accounts[index].total,
        target: data.targetAmount,
        color: data.color,
      );
    });
  }

  void _handleDeleteAccount(int index) {
    setState(() {
      _accounts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Cuentas de ahorro',
                  style: GoogleFonts.newsreader(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return ExpandableAccountCard(
                      name: account.name,
                      total: account.total,
                      target: account.target,
                      color: account.color,
                      onEdit: (data) => _handleEditAccount(index, data),
                      onDelete: () => _handleDeleteAccount(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.usd,
        foregroundColor: AppColors.ink,
        elevation: 0,
        onPressed: _handleCreateAccount,
        child: const Icon(Icons.add),
      ),
    );
  }
}