import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountListTile extends ConsumerWidget {
  final Account account;
  final int balance;
  const AccountListTile({required this.account, required this.balance, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPositiveBalance = balance >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConst.spacingM,
        vertical: UIConst.spacingXS,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UIConst.spacingM,
        vertical: UIConst.spacingS,
      ),
      decoration: BoxDecoration(
        color: ColorConst.textOnPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UIConst.radiusM),
        border: Border.all(
          color: ColorConst.textOnPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Account icon
          Container(
            padding: const EdgeInsets.all(UIConst.spacingS),
            decoration: BoxDecoration(
              color: ColorConst.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: ColorConst.textOnPrimary,
              size: 20,
            ),
          ),

          const SizedBox(width: UIConst.spacingM),

          // Account name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name ?? 'Unnamed Account',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ColorConst.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Account Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorConst.textOnPrimary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat(balance.toString()),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorConst.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (!isPositiveBalance)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConst.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConst.expenseRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(UIConst.radiusS),
                  ),
                  child: Text(
                    'Deficit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorConst.expenseRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
