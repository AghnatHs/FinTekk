import 'dart:async';

import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final transactionCategoryProvider =
    AsyncNotifierProvider<TransactionCategoryNotifier, List<TranscactionCategory>>(
        TransactionCategoryNotifier.new);

class TransactionCategoryNotifier extends AsyncNotifier<List<TranscactionCategory>> {
  DatabaseHelper? db;

  @override
  FutureOr<List<TranscactionCategory>> build() async {
    db = ref.watch(databaseProvider);

    List<Map<dynamic, dynamic>> query = await db!.getAllTransactionCategories();
    List<TranscactionCategory> transactionCategories =
        query.map((data) => TranscactionCategory.fromMap(data)).toList();

    return transactionCategories;
  }

  void addTransactionCategory({required String name}) async {
    String id = 'tsctgry-${const Uuid().v7()}';
    await db!.addTransactionCategory(TranscactionCategory(id: id, name: name));
    ref.invalidateSelf();
  }

  void updateTransactionCategory(
      {required String transactionCategoryId, required String newName}) async {
    await db!.updateTransactionCategory(transactionCategoryId, newName);
    ref.invalidateSelf();
    ref.invalidate(transactionProvider);
  }

/*   void test() async {
    print(await db!.getAllTransactions());
    print(await db!.getAllTransactionCategories());
    print(await db!.getAllAccounts());
  } */
}
