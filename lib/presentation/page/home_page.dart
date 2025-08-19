import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/account/account_with_balance_notifier.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/list_tile/account_list_tile.dart';
import 'package:fl_finance_mngt/presentation/widget/list_tile/internal_transfer_list_tile.dart';
import 'package:fl_finance_mngt/presentation/widget/list_tile/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final localTransactionTilesShowOptionsState = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool transactionTilesIsShowingOption = ref.watch(localTransactionTilesShowOptionsState);
    final theme = Theme.of(context);

    ScrollController accountListScrollController = ScrollController();
    ScrollController transactionListScrollController = ScrollController();

    List<Account>? accounts = ref.watch(accountProvider).value;
    Map<String, int> accountsBalance = ref.watch(accountBalanceProvider);
    int totalAccountBalance = ref.watch(totalAccountBalanceProvider);

    List<InternalTransfer>? internalTransfers = ref.watch(internalTransferProvider).value;

    var transactions = ref.watch(transactionProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorConst.surfaceLight,
            ColorConst.surfaceLight.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            UIConst.spacingM,
            UIConst.spacingM,
            UIConst.spacingM,
            UIConst.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(totalAccountBalance, theme),
              const SizedBox(height: UIConst.spacingL),
              _buildAccountsCard(accounts, accountsBalance, accountListScrollController, theme),
              const SizedBox(height: UIConst.spacingL),
              _buildTransactionsHeader(transactions, transactionTilesIsShowingOption, ref, theme),
              const SizedBox(height: UIConst.spacingM),
              _buildTransactionsList(transactions, internalTransfers,
                  transactionTilesIsShowingOption, transactionListScrollController, ref, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(int totalBalance, ThemeData theme) {
    final isPositive = totalBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConst.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConst.primaryGreen,
            ColorConst.primaryGreenDark,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        boxShadow: [
          BoxShadow(
            color: ColorConst.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorConst.textOnPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: UIConst.spacingS),
                    Text(
                      currencyFormat(totalBalance.toString()),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: ColorConst.textOnPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(UIConst.spacingM),
                decoration: BoxDecoration(
                  color: ColorConst.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(UIConst.radiusL),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: ColorConst.textOnPrimary,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConst.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConst.spacingM,
              vertical: UIConst.spacingS,
            ),
            decoration: BoxDecoration(
              color: ColorConst.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: ColorConst.textOnPrimary,
                  size: 16,
                ),
                const SizedBox(width: UIConst.spacingS),
                Text(
                  'Combined balance from all accounts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorConst.textOnPrimary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsCard(List<Account>? accounts, Map<String, int> accountsBalance,
      ScrollController scrollController, ThemeData theme) {
    return Card(
      elevation: UIConst.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConst.radiusL),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorConst.primaryGreen,
              ColorConst.primaryGreenLight,
            ],
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingL,
            vertical: UIConst.spacingS,
          ),
          childrenPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: ColorConst.textOnPrimary,
          collapsedIconColor: ColorConst.textOnPrimary,
          textColor: ColorConst.textOnPrimary,
          collapsedTextColor: ColorConst.textOnPrimary,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: ColorConst.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: ColorConst.textOnPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accounts & Balances',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: ColorConst.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${accounts?.length ?? 0} account${(accounts?.length ?? 0) != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorConst.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Container(
              margin: const EdgeInsets.all(UIConst.spacingM),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen,
                borderRadius: BorderRadius.circular(UIConst.radiusM),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(UIConst.spacingM),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Account Name',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: ColorConst.textOnPrimary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Balance',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: ColorConst.textOnPrimary.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: ColorConst.textOnPrimary.withValues(alpha: 0.2),
                    thickness: 1,
                  ),

                  // Accounts List
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      thickness: 3,
                      thumbVisibility: true,
                      radius: const Radius.circular(UIConst.radiusS),
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: UIConst.spacingS),
                        itemCount: accounts?.length ?? 0,
                        itemBuilder: (context, index) {
                          Account account = accounts![index];
                          int balance = accountsBalance[account.id] ?? 0;
                          return AccountListTile(account: account, balance: balance);
                        },
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

  Widget _buildTransactionsHeader(AsyncValue<List<Transactionn>> transactions,
      bool isShowingOptions, WidgetRef ref, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: ColorConst.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (transactions.value != null)
                Text(
                  '${transactions.value!.length} transaction${transactions.value!.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorConst.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (transactions.value != null && transactions.value!.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: isShowingOptions
                  ? ColorConst.primaryGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
            child: TextButton.icon(
              onPressed: () {
                ref.read(localTransactionTilesShowOptionsState.notifier).update((state) => !state);
              },
              icon: Icon(
                isShowingOptions ? Icons.visibility_off_rounded : Icons.edit_rounded,
                size: 18,
              ),
              label: Text(
                isShowingOptions ? 'Hide Options' : 'Edit Mode',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: ColorConst.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConst.spacingM,
                  vertical: UIConst.spacingS,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionsList(
      AsyncValue<List<Transactionn>> transactions,
      List<InternalTransfer>? internalTransfers,
      bool isShowingOptions,
      ScrollController scrollController,
      WidgetRef ref,
      ThemeData theme) {
    return transactions.when(
      data: (transactionsList) {
        if (transactionsList.isNotEmpty) {
          Set<Object> items = ref
              .watch(transactionProvider.notifier)
              .getGroupedTransactionsAndInternalTransfersByDate(
                  transactionsList, internalTransfers!);

          Map<DateTime, int> dailySummaries =
              ref.watch(transactionProvider.notifier).getDailyTotalSummary(transactionsList);

          return Card(
            elevation: UIConst.elevationLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusL),
            ),
            child: Container(
              padding: const EdgeInsets.all(UIConst.spacingM),
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items.elementAt(index);
                        
                  if (item is DateTime) {
                    int dailySummary =
                        dailySummaries[DateTime(item.year, item.month, item.day)] ?? 0;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: UIConst.spacingS,
                        horizontal: UIConst.spacingS,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConst.spacingS,
                        vertical: UIConst.spacingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            ColorConst.primaryGreen.withValues(alpha: 0.1),
                            ColorConst.primaryGreen.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(UIConst.radiusM),
                        border: Border.all(
                          color: ColorConst.primaryGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(UIConst.spacingS),
                            decoration: BoxDecoration(
                              color: ColorConst.primaryGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(UIConst.radiusS),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: ColorConst.primaryGreen,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: UIConst.spacingM),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, d MMM y').format(item),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: ColorConst.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConst.spacingM,
                              vertical: UIConst.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: dailySummary >= 0
                                  ? ColorConst.incomeGreen.withValues(alpha: 0.1)
                                  : ColorConst.expenseRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(UIConst.radiusS),
                            ),
                            child: Text(
                              currencyFormat(dailySummary.toString()),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: dailySummary >= 0
                                    ? ColorConst.incomeGreen
                                    : ColorConst.expenseRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (item is InternalTransfer) {
                    return InternalTransferListTile(
                      internalTransfer: item,
                      isShowingOption: isShowingOptions,
                    );
                  } else if (item is Transactionn) {
                    return TransactionListTile(
                      transaction: item,
                      isShowingOption: isShowingOptions,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        } else {
          return _buildEmptyState(theme);
        }
      },
      error: (e, st) => _buildErrorState(theme),
      loading: () => _buildLoadingState(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      elevation: UIConst.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(UIConst.spacingXL),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConst.spacingL),
              decoration: BoxDecoration(
                color: ColorConst.neutralGray.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: ColorConst.neutralGray,
              ),
            ),
            const SizedBox(height: UIConst.spacingL),
            Text(
              'No Transactions Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ColorConst.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: UIConst.spacingS),
            Text(
              'Start tracking your finances by adding your first transaction',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorConst.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Card(
      elevation: UIConst.elevationLow,
      child: Padding(
        padding: const EdgeInsets.all(UIConst.spacingL),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: ColorConst.expenseRed,
            ),
            const SizedBox(height: UIConst.spacingM),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorConst.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Please try again later',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorConst.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Card(
      elevation: UIConst.elevationLow,
      child: Container(
        padding: const EdgeInsets.all(UIConst.spacingXL),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: UIConst.spacingL),
            Text(
              'Loading transactions...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorConst.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
