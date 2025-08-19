import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final localCachedTransactionCategoryIdProvider = StateProvider<String>((ref) {
  final categories = ref.read(transactionCategoryProvider).value;
  return (categories != null && categories.isNotEmpty) ? categories[0].id! : '';
});
final localCachedSourceAccountIdProvider = StateProvider<String>((ref) {
  final accounts = ref.read(accountProvider).value;
  return (accounts != null && accounts.isNotEmpty) ? accounts[0].id! : '';
});
final localCachedDestinationAccountIdProvider = StateProvider<String>((ref) {
  final accounts = ref.read(accountProvider).value;
  return (accounts != null && accounts.length > 1) ? accounts[1].id! : '';
});
final localAmountFormattedPreviewProvider = StateProvider<String>((ref) => '0');

class InputInternalTransferDialog extends ConsumerStatefulWidget {
  const InputInternalTransferDialog({super.key});

  @override
  ConsumerState<InputInternalTransferDialog> createState() => InputInternalTransferDialogState();
}

class InputInternalTransferDialogState extends ConsumerState<InputInternalTransferDialog> {
  final TextEditingController amountTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Account> accounts = ref.watch(accountProvider).value!;
    String sourceAccountId = ref.watch(localCachedSourceAccountIdProvider);
    String destinationAccountId = ref.watch(localCachedDestinationAccountIdProvider);
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorConst.gradientStart.withValues(alpha: 0.05),
              ColorConst.gradientEnd.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Add Internal Transfer',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ColorConst.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: ColorConst.primaryGreen,
            foregroundColor: ColorConst.textOnPrimary,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: UIConst.spacingM),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: ColorConst.textOnPrimary,
                  size: 28,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(UIConst.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount Preview Card
                      _buildAmountPreviewCard(theme),

                      const SizedBox(height: UIConst.spacingXL),

                      // Form Fields Card
                      _buildFormFieldsCard(accounts, sourceAccountId, destinationAccountId, theme),

                      const SizedBox(height: UIConst.spacingXL),

                      // Action Buttons
                      _buildActionButtons(sourceAccountId, destinationAccountId, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountPreviewCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(UIConst.spacingXL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConst.primaryGreen.withValues(alpha: 0.1),
            ColorConst.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.swap_horiz_rounded,
            size: 48,
            color: ColorConst.primaryGreen,
          ),
          const SizedBox(height: UIConst.spacingM),
          Text(
            rawCurrencyFormat(amountTextController.text.isEmpty ? '0' : amountTextController.text),
            style: theme.textTheme.displaySmall?.copyWith(
              color: ColorConst.primaryGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConst.spacingS),
          Text(
            'Transfer Amount',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorConst.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldsCard(List<Account> accounts, String sourceAccountId,
      String destinationAccountId, ThemeData theme) {
    return Card(
      elevation: UIConst.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConst.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConst.textPrimary,
              ),
            ),
            const SizedBox(height: UIConst.spacingL),

            // Amount Input
            TextFormField(
              controller: amountTextController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount (e.g., 125000)',
                prefixIcon: const Icon(
                  Icons.currency_exchange_rounded,
                  color: ColorConst.primaryGreen,
                ),
                suffixIcon: amountTextController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          amountTextController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (String? value) {
                setState(() {});
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: UIConst.spacingL),

            // Source Account
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Source Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.expenseRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: sourceAccountId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: ColorConst.expenseRed,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UIConst.spacingM,
                      vertical: UIConst.spacingS,
                    ),
                  ),
                  items: accounts.map((Account account) {
                    return DropdownMenuItem<String>(
                      value: account.id!,
                      child: Text(account.name!),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    ref.read(localCachedSourceAccountIdProvider.notifier).update((state) => value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingL),

            // Destination Account
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Destination Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.incomeGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: destinationAccountId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: ColorConst.incomeGreen,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UIConst.spacingM,
                      vertical: UIConst.spacingS,
                    ),
                  ),
                  items: accounts.map((Account account) {
                    return DropdownMenuItem<String>(
                      value: account.id!,
                      child: Text(account.name!),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    ref
                        .read(localCachedDestinationAccountIdProvider.notifier)
                        .update((state) => value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingL),

            // Hint Card
            Container(
              padding: const EdgeInsets.all(UIConst.spacingM),
              decoration: BoxDecoration(
                color: ColorConst.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConst.radiusM),
                border: Border.all(
                  color: ColorConst.accentBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: ColorConst.accentBlue,
                    size: 20,
                  ),
                  const SizedBox(width: UIConst.spacingS),
                  Expanded(
                    child: Text(
                      'Check your internal transfers in \'home\'',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorConst.accentBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String sourceAccountId, String destinationAccountId, ThemeData theme) {
    final isFormValid = amountTextController.text.isNotEmpty &&
        int.tryParse(amountTextController.text) != null &&
        int.parse(amountTextController.text) > 0 &&
        sourceAccountId.isNotEmpty &&
        destinationAccountId.isNotEmpty &&
        sourceAccountId != destinationAccountId;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: UIConst.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConst.radiusM),
              ),
            ),
          ),
        ),
        const SizedBox(width: UIConst.spacingM),
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: isFormValid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      HapticFeedback.mediumImpact();
                      String linkedTransferId = const Uuid().v7();
                      // source
                      ref.read(internalTransferProvider.notifier).addInternalTransfer(
                          linkedTransferId: linkedTransferId,
                          accountId: sourceAccountId,
                          amount: int.tryParse(amountTextController.text)!,
                          type: TransactionConst.expense,
                          date: DateTime.now().toIso8601String());
                      // destination
                      ref.read(internalTransferProvider.notifier).addInternalTransfer(
                          linkedTransferId: linkedTransferId,
                          accountId: destinationAccountId,
                          amount: int.tryParse(amountTextController.text)!,
                          type: TransactionConst.income,
                          date: DateTime.now().toIso8601String());
                      pushGlobalSnackbar(message: 'Internal Transfer Added');
                      Navigator.pop(context);
                    }
                  }
                : null,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Add Transfer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primaryGreen,
              foregroundColor: ColorConst.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: UIConst.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConst.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
