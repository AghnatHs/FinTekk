import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// {"accountId": balance}
final accountBalanceProvider =
    StateNotifierProvider<AccountWithBalanceNotifier, Map<String, int>>((ref) {
  try {
    final List<Account> accounts = ref.watch(accountProvider).value!;
    final List<Transactionn> transactions = ref.watch(transactionProvider).value!;
    final List<InternalTransfer> internalTransfers =
        ref.watch(internalTransferProvider).value!;
    final Map<String, int> state = {};

    for (var i = 0; i < accounts.length; i++) {
      var accountId = accounts[i].id!;
      for (var j = 0; j < transactions.length; j++) {
        if (transactions[j].accountId == accountId) {
          var transactionType = transactions[j].type;
          var transactionAmount = transactionType == TransactionConst.income
              ? transactions[j].amount
              : transactions[j].amount * -1;
          state.update(
            accountId,
            (value) => value + transactionAmount,
            ifAbsent: () => transactionAmount,
          );
        }
      }

      for (var k = 0; k < internalTransfers.length; k++) {
        if (internalTransfers[k].accountId == accountId) {
          var iTransferType = internalTransfers[k].type;
          var iTransferAmount = iTransferType == TransactionConst.income
              ? internalTransfers[k].amount
              : internalTransfers[k].amount * -1;
          state.update(
            accountId,
            (value) => value + iTransferAmount,
            ifAbsent: () => iTransferAmount,
          );
        }
      }
    }

    return AccountWithBalanceNotifier(state);
  } catch (e) {
    return AccountWithBalanceNotifier({});
  }
});
final totalAccountBalanceProvider = StateProvider<int>((ref) {
  final accountsBalance = ref.watch(accountBalanceProvider);
  int totalAccountBalance = 0;

  for (int accountBalance in accountsBalance.values) {
    totalAccountBalance += accountBalance;
  }

  return totalAccountBalance;
});

class AccountWithBalanceNotifier extends StateNotifier<Map<String, int>> {
  AccountWithBalanceNotifier(super.state);
}
