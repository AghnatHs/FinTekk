import 'dart:async';

import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final accountProvider =
    AsyncNotifierProvider<AccountNotifier, List<Account>>(AccountNotifier.new);

class AccountNotifier extends AsyncNotifier<List<Account>> {
  DatabaseHelper? db;

  @override
  FutureOr<List<Account>> build() async {
    db = ref.watch(databaseProvider);

    List<Map<dynamic, dynamic>> query = await db!.getAllAccounts();
    List<Account> accounts = query.map((data) => Account.fromMap(data)).toList();

    return accounts;
  }

  void addAccount({required String name}) async {
    String id = 'account-${const Uuid().v7()}';
    await db!.addAccount(Account(id: id, name: name));
    ref.invalidateSelf();
  }

  void updateAccount({required String accountId, required String newName}) async {
    await db!.updateAccount(accountId, newName);
    ref.invalidateSelf();
    ref.invalidate(transactionProvider);
  }
}
