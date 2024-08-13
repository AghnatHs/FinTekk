import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/account/account_with_balance_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/list_tile/account_list_tile.dart';
import 'package:fl_finance_mngt/presentation/widget/list_tile/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO : add color coded for each account and category

final localTransactionTilesShowOptionsState = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool transactionTilesIsShowingOption = ref.watch(localTransactionTilesShowOptionsState);

    ScrollController accountListScrollController = ScrollController();
    ScrollController transactionListScrollController = ScrollController();

    List<Account>? accounts = ref.watch(accountProvider).value;
    Map<String, int> accountsBalance = ref.watch(accountBalanceProvider);
    int totalAccountBalance = ref.watch(totalAccountBalanceProvider);

    var transactions = ref.watch(transactionProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accounts List
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              textColor: Colors.white,
              collapsedTextColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor.withGreen(130),
              collapsedBackgroundColor: Theme.of(context).primaryColor,
              title: const Text('Accounts & Balance'),
              children: [
                Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.zero,
                        topRight: Radius.zero,
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 12, 15, 2),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              'Account Name',
                              style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
                            )),
                            Expanded(
                                child: Text(
                              'Balance',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
                            )),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1),
                      // Accounts
                      Flexible(
                        child: Scrollbar(
                          controller: accountListScrollController,
                          thickness: 5,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: accountListScrollController,
                            child: Center(
                              child: Column(
                                children: [
                                  // Accounts
                                  ...List.generate(accounts?.length ?? 0, (int index) {
                                    Account account = accounts![index];
                                    int balance = accountsBalance[account.id] ?? 0;
                                    return AccountListTile(account: account, balance: balance);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(thickness: 1),
                      // Total balance
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 7),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              'Total Balance',
                              style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
                            )),
                            Expanded(
                                child: Text(
                              currencyFormat(totalAccountBalance.toString()),
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Transaction divider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13), child: Text('Transactions')),
              transactions.value!.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        ref
                            .read(localTransactionTilesShowOptionsState.notifier)
                            .update((state) => !state);
                      },
                      child: Text(
                          transactionTilesIsShowingOption ? 'Hide Options' : 'Show Options'),
                    )
                  : Container()
            ],
          ),
          const Divider(),
          // Transaction ListView
          transactions.when(
            data: (transactions) {
              if (transactions.isNotEmpty) {
                Set<Object> items = ref
                    .watch(transactionProvider.notifier)
                    .getGroupedTransactionsByDate(transactions);

                Map<DateTime, int> dailySummaries =
                    ref.watch(transactionProvider.notifier).getDailyTotalSummary(transactions);
                // widget
                return Flexible(
                  child: Scrollbar(
                    controller: transactionListScrollController,
                    thumbVisibility: true,
                    thickness: 5,
                    child: ListView.builder(
                      controller: transactionListScrollController,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items.elementAt(index);

                        return item is DateTime
                            ? RichText(
                                text: TextSpan(
                                  text: DateFormat('d MMM y ').format(item),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  children: [
                                    TextSpan(
                                      text:
                                          ' [${currencyFormat(dailySummaries[DateTime(item.year, item.month, item.day)].toString())}]',
                                      style: TextStyle(
                                        color: dailySummaries[DateTime(
                                                        item.year, item.month, item.day)]!
                                                    .sign >=
                                                0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ) /* Text(
                                DateFormat('d MMM y').format(item),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ) */
                            : TransactionListTile(
                                transaction: item as Transactionn,
                                isShowingOption: transactionTilesIsShowingOption,
                              );
                      },
                    ),
                  ),
                );
              } else {
                return const Expanded(
                  child: Center(
                    child: Text('No Transactions'),
                  ),
                );
              }
            },
            error: (e, st) => const Center(child: Text('An Unexpected Error Occured')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
