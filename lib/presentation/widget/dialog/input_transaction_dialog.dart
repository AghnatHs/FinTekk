import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localCachedTransactionCategoryIdProvider = StateProvider<String>((ref) {
  final categories = ref.read(transactionCategoryProvider).value;
  return (categories != null && categories.isNotEmpty) ? categories[0].id! : '';
});
final localCachedAccountIdProvider = StateProvider<String>((ref) {
  final accounts = ref.read(accountProvider).value;
  return (accounts != null && accounts.isNotEmpty) ? accounts[0].id! : '';
});
final localTransactionTypeProvider = StateProvider<String>((ref) => TransactionConst.income);
final localAmountFormattedPreviewProvider = StateProvider<String>((ref) => '0');

class InputTransactionDialog extends ConsumerStatefulWidget {
  const InputTransactionDialog({super.key});

  @override
  ConsumerState<InputTransactionDialog> createState() => InputTransactionDialogState();
}

class InputTransactionDialogState extends ConsumerState<InputTransactionDialog>
    with TickerProviderStateMixin {
  final TextEditingController amountTextController = TextEditingController();
  final TextEditingController descriptionTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value ?? [];
    List<Account> accounts = ref.watch(accountProvider).value ?? [];
    String transactionCategoryId = ref.watch(localCachedTransactionCategoryIdProvider);
    String accountId = ref.watch(localCachedAccountIdProvider);
    String type = ref.watch(localTransactionTypeProvider);

    if (transactionCategoryId.isEmpty && transactionCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localCachedTransactionCategoryIdProvider.notifier).state =
            transactionCategories[0].id!;
      });
      transactionCategoryId = transactionCategories[0].id!;
    }

    if (accountId.isEmpty && accounts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localCachedAccountIdProvider.notifier).state = accounts[0].id!;
      });
      accountId = accounts[0].id!;
    }

    if (accounts.isEmpty || transactionCategories.isEmpty) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Transaction'),
            backgroundColor: ColorConst.primaryGreen,
            foregroundColor: ColorConst.textOnPrimary,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading accounts and categories...'),
              ],
            ),
          ),
        ),
      );
    }

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
              'Add Transaction',
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                child: Icon(
                  type == TransactionConst.income
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
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
                      _buildAmountPreviewCard(type, theme),

                      const SizedBox(height: UIConst.spacingXL),

                      // Transaction Type Selector
                      _buildTransactionTypeSelector(type, theme),

                      const SizedBox(height: UIConst.spacingL),

                      // Form Fields Card
                      _buildFormFieldsCard(
                          accounts, transactionCategories, accountId, transactionCategoryId, theme),

                      const SizedBox(height: UIConst.spacingXL),

                      // Action Buttons
                      _buildActionButtons(type, transactionCategoryId, accountId, theme),
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

  Widget _buildAmountPreviewCard(String type, ThemeData theme) {
    return Card(
      elevation: UIConst.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(UIConst.spacingXL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConst.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: type == TransactionConst.income
                ? [
                    ColorConst.incomeGreen.withValues(alpha: 0.1),
                    ColorConst.incomeGreen.withValues(alpha: 0.05),
                  ]
                : [
                    ColorConst.expenseRed.withValues(alpha: 0.1),
                    ColorConst.expenseRed.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: Column(
          children: [
            Icon(
              type == TransactionConst.income
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 48,
              color:
                  type == TransactionConst.income ? ColorConst.incomeGreen : ColorConst.expenseRed,
            ),
            const SizedBox(height: UIConst.spacingM),
            Text(
              currencyFormat(
                  amountTextController.text.isEmpty ? '0' : amountTextController.text, type),
              style: theme.textTheme.displaySmall?.copyWith(
                color: type == TransactionConst.income
                    ? ColorConst.incomeGreen
                    : ColorConst.expenseRed,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConst.spacingS),
            Text(
              type == TransactionConst.income ? 'Income Amount' : 'Expense Amount',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorConst.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector(String type, ThemeData theme) {
    return Card(
      elevation: UIConst.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConst.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConst.textPrimary,
              ),
            ),
            const SizedBox(height: UIConst.spacingM),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UIConst.radiusM),
                color: ColorConst.surfaceLight,
              ),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: TransactionConst.income,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 20,
                          color: type == TransactionConst.income
                              ? ColorConst.textOnPrimary
                              : ColorConst.incomeGreen,
                        ),
                        const SizedBox(width: UIConst.spacingS),
                        const Text('Income'),
                      ],
                    ),
                  ),
                  ButtonSegment(
                    value: TransactionConst.expense,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_down_rounded,
                          size: 20,
                          color: type == TransactionConst.expense
                              ? ColorConst.textOnPrimary
                              : ColorConst.expenseRed,
                        ),
                        const SizedBox(width: UIConst.spacingS),
                        const Text('Expense'),
                      ],
                    ),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (Set<String> newSelection) {
                  HapticFeedback.lightImpact();
                  ref
                      .read(localTransactionTypeProvider.notifier)
                      .update((state) => newSelection.first);
                  setState(() {});
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: type == TransactionConst.income
                      ? ColorConst.incomeGreen
                      : ColorConst.expenseRed,
                  selectedForegroundColor: ColorConst.textOnPrimary,
                  side: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldsCard(
      List<Account> accounts,
      List<TranscactionCategory> transactionCategories,
      String accountId,
      String transactionCategoryId,
      ThemeData theme) {
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
              'Transaction Details',
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

            // Description Input
            TextFormField(
              controller: descriptionTextController,
              maxLength: 50,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Coffee, Salary, Rent',
                prefixIcon: const Icon(
                  Icons.description_outlined,
                  color: ColorConst.primaryGreen,
                ),
                suffixIcon: descriptionTextController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          descriptionTextController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: UIConst.spacingL),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: accountId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: ColorConst.primaryGreen,
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
                    ref.read(localCachedAccountIdProvider.notifier).update((state) => value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingM),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: transactionCategoryId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: ColorConst.primaryGreen,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UIConst.spacingM,
                      vertical: UIConst.spacingS,
                    ),
                  ),
                  items: transactionCategories.map((TranscactionCategory category) {
                    return DropdownMenuItem<String>(
                      value: category.id!,
                      child: Text(category.name!),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    ref
                        .read(localCachedTransactionCategoryIdProvider.notifier)
                        .update((state) => value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingM),

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
                      'Add new accounts or categories in Settings',
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

  Widget _buildActionButtons(
      String type, String transactionCategoryId, String accountId, ThemeData theme) {
    final isFormValid = amountTextController.text.isNotEmpty &&
        int.tryParse(amountTextController.text) != null &&
        int.parse(amountTextController.text) > 0 &&
        transactionCategoryId.isNotEmpty &&
        accountId.isNotEmpty;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
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
                      ref.read(transactionProvider.notifier).addTransaction(
                            transactionCategoryId: transactionCategoryId,
                            accountId: accountId,
                            date: DateTime.now().toIso8601String(),
                            amount: int.parse(amountTextController.text),
                            description: descriptionTextController.text,
                            type: type,
                            category: '',
                            categoryColor: 0,
                            account: '',
                          );
                      pushGlobalSnackbar(
                        message:
                            '${type == TransactionConst.income ? "Income" : "Expense"} added successfully!',
                      );
                      Navigator.pop(context);
                    }
                  }
                : null,
            icon: Icon(
              type == TransactionConst.income
                  ? Icons.add_circle_rounded
                  : Icons.remove_circle_rounded,
            ),
            label: Text(
              'ADD ${type.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid
                  ? (type == TransactionConst.income
                      ? ColorConst.incomeGreen
                      : ColorConst.expenseRed)
                  : ColorConst.neutralGray,
              foregroundColor: ColorConst.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: UIConst.spacingM),
              elevation: isFormValid ? UIConst.elevationMedium : 0,
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
