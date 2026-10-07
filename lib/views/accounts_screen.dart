import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../Models/account.dart';
import '../Controllers/accounts_controller.dart';
import '../widgets/expandable_account_card.dart';
import '../widgets/create_account_sheet.dart';
import '../widgets/edit_account_sheet.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountsController()..loadAccounts(),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  Future<void> _handleCreateAccount(BuildContext context, AccountsController controller) async {
    final result = await showCreateAccountSheet(context);
    if (result == null) return;

    final success = await controller.createAccount(
      name: result.name,
      initialAmount: result.initialAmount,
      targetAmount: result.targetAmount,
      color: result.color,
    );

    if (!success && context.mounted) {
      _showErrorSnackBar(context, controller.errorMessage);
    }
  }

  Future<void> _handleEditAccount(
    BuildContext context,
    AccountsController controller,
    Account account,
    EditAccountData data,
  ) async {
    final updated = Account(
      id: account.id,
      name: data.name,
      total: account.total, // el total no se edita a mano
      targetAmount: data.targetAmount,
      color: data.color,
    );
    final success = await controller.updateAccount(updated);
    if (!success && context.mounted) {
      _showErrorSnackBar(context, controller.errorMessage);
    }
  }

  Future<void> _handleDeleteAccount(
    BuildContext context,
    AccountsController controller,
    String accountId,
  ) async {
    final success = await controller.deleteAccount(accountId);
    if (!success && context.mounted) {
      _showErrorSnackBar(context, controller.errorMessage);
    }
  }

  void _showErrorSnackBar(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'Ocurrió un error, intenta de nuevo',
          style: GoogleFonts.ibmPlexSans(),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AccountsController>();

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
              Expanded(child: _buildBody(controller)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts_fab',
        backgroundColor: AppColors.usd,
        foregroundColor: AppColors.ink,
        elevation: 0,
        onPressed: () => _handleCreateAccount(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(AccountsController controller) {
    if (controller.loading && controller.accounts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.usd),
      );
    }

    return Builder(
      builder: (context) => ListView.builder(
        itemCount: controller.accounts.length,
        itemBuilder: (context, index) {
          final account = controller.accounts[index];
          return ExpandableAccountCard(
            name: account.name,
            total: account.total,
            target: account.targetAmount,
            color: account.color,
            onEdit: (data) => _handleEditAccount(context, controller, account, data),
            onDelete: () => _handleDeleteAccount(context, controller, account.id),
          );
        },
      ),
    );
  }
}