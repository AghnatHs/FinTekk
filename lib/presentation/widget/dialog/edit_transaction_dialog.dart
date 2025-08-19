import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
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
final localAmountFormattedPreviewProvider = StateProvider<String>((ref) => '0');

class EditTransactionDialog extends ConsumerStatefulWidget {
  final Transactionn transaction;
  const EditTransactionDialog({required this.transaction, super.key});

  @override
  ConsumerState<EditTransactionDialog> createState() => EditTransactionDialogState();
}

class EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  late String id;
  late TextEditingController amountTextController;
  late String date;
  late TextEditingController descriptionTextController;
  late String transactionCategoryId;
  late String accountId;
  late String type;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    id = widget.transaction.id;
    amountTextController = TextEditingController(text: widget.transaction.amount.toString());
    date = widget.transaction.date;
    descriptionTextController = TextEditingController(text: widget.transaction.description);
    transactionCategoryId = widget.transaction.transactionCategoryId;
    accountId = widget.transaction.accountId;
    type = widget.transaction.type;
  }

  @override
  Widget build(BuildContext context) {
    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value!;
    List<Account> accounts = ref.watch(accountProvider).value!;
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
              'Edit Transaction',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ColorConst.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor:
                type == TransactionConst.income ? ColorConst.incomeGreen : ColorConst.expenseRed,
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
                      _buildAmountPreviewCard(theme),

                      const SizedBox(height: UIConst.spacingL),

                      // Transaction Type Selector
                      _buildTransactionTypeCard(theme),

                      const SizedBox(height: UIConst.spacingL),

                      // Form Fields Card
                      _buildFormFieldsCard(accounts, transactionCategories, theme),

                      const SizedBox(height: UIConst.spacingXL),

                      // Action Buttons
                      _buildActionButtons(theme),
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
    Color typeColor =
        type == TransactionConst.income ? ColorConst.incomeGreen : ColorConst.expenseRed;

    return Container(
      padding: const EdgeInsets.all(UIConst.spacingXL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.1),
            typeColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(
            type == TransactionConst.income
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 48,
            color: typeColor,
          ),
          const SizedBox(height: UIConst.spacingM),
          Text(
            currencyFormat(
                amountTextController.text.isEmpty ? '0' : amountTextController.text, type),
            style: theme.textTheme.displaySmall?.copyWith(
              color: typeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConst.spacingS),
          Text(
            'Transaction Amount',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorConst.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeCard(ThemeData theme) {
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
              'Transaction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConst.textPrimary,
              ),
            ),
            const SizedBox(height: UIConst.spacingM),
            Container(
              padding: const EdgeInsets.all(UIConst.spacingXS),
              decoration: BoxDecoration(
                color: ColorConst.surfaceLight,
                borderRadius: BorderRadius.circular(UIConst.radiusM),
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
                          size: 18,
                          color: type == TransactionConst.income
                              ? Colors.white
                              : ColorConst.incomeGreen,
                        ),
                        const SizedBox(width: UIConst.spacingXS),
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
                          size: 18,
                          color: type == TransactionConst.expense
                              ? Colors.white
                              : ColorConst.expenseRed,
                        ),
                        const SizedBox(width: UIConst.spacingXS),
                        const Text('Expense'),
                      ],
                    ),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    type = newSelection.first;
                  });
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return type == TransactionConst.income
                          ? ColorConst.incomeGreen
                          : ColorConst.expenseRed;
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return ColorConst.textPrimary;
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConst.radiusS),
                    ),
                  ),
                  side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide.none;
                    }
                    return BorderSide(
                      color: ColorConst.neutralGray.withValues(alpha: 0.3),
                      width: 1,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldsCard(
      List<Account> accounts, List<TranscactionCategory> transactionCategories, ThemeData theme) {
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
                prefixIcon: Icon(
                  Icons.currency_exchange_rounded,
                  color: type == TransactionConst.income
                      ? ColorConst.incomeGreen
                      : ColorConst.expenseRed,
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
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (e.g., grocery, salary)',
                prefixIcon: const Icon(
                  Icons.description_outlined,
                  color: ColorConst.accentBlue,
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

            // Account Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: accountId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: ColorConst.accentBlue,
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
                    setState(() {
                      accountId = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingL),

            // Category Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorConst.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConst.spacingS),
                DropdownButtonFormField<String>(
                  initialValue: transactionCategoryId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: ColorConst.accentPurple,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UIConst.spacingM,
                      vertical: UIConst.spacingS,
                    ),
                  ),
                  items: transactionCategories.map((TranscactionCategory category) {
                    return DropdownMenuItem<String>(
                      value: category.id!,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(category.color!),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: UIConst.spacingS),
                          Text(category.name!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      transactionCategoryId = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: UIConst.spacingL),

            // Hint Card
            Container(
              padding: const EdgeInsets.all(UIConst.spacingM),
              decoration: BoxDecoration(
                color: ColorConst.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConst.radiusM),
                border: Border.all(
                  color: ColorConst.accentOrange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: ColorConst.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: UIConst.spacingS),
                  Expanded(
                    child: Text(
                      'Add new accounts or categories in Settings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorConst.accentOrange,
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

  Widget _buildActionButtons(ThemeData theme) {
    final isFormValid = amountTextController.text.isNotEmpty &&
        int.tryParse(amountTextController.text) != null &&
        int.parse(amountTextController.text) > 0 &&
        accountId.isNotEmpty &&
        transactionCategoryId.isNotEmpty;

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
                      ref.read(transactionProvider.notifier).updateTransaction(
                            id: id,
                            transactionCategoryId: transactionCategoryId,
                            accountId: accountId,
                            date: date,
                            amount: int.tryParse(amountTextController.text)!,
                            description: descriptionTextController.text,
                            type: type,
                            category: '',
                            categoryColor: 0,
                            account: '',
                          );
                      pushGlobalSnackbar(message: 'Transaction successfully updated');
                      Navigator.pop(context);
                    }
                  }
                : null,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  type == TransactionConst.income ? ColorConst.incomeGreen : ColorConst.expenseRed,
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
