import 'dart:async';
import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<Transactionn>>(TransactionNotifier.new);

class TransactionNotifier extends AsyncNotifier<List<Transactionn>> {
  DatabaseHelper? db;

  @override
  FutureOr<List<Transactionn>> build() async {
    db = ref.watch(databaseProvider);

    List<Map<dynamic, dynamic>> query = await db!.getAllTransactions();
    List<Transactionn> transactions = query.map((data) => Transactionn.fromMap(data)).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));

    return transactions.reversed.toList();
  }

  void addTransaction(
      {required String transactionCategoryId,
      required String accountId,
      required String date,
      required int amount,
      required String description,
      required String type,
      required String category,
      required String account}) async {
    String id = 'transaction-${const Uuid().v7()}';
    await db!.addTransaction(Transactionn(
        id: id,
        transactionCategoryId: transactionCategoryId,
        accountId: accountId,
        date: date,
        amount: amount,
        description: description,
        type: type,
        category: category,
        account: account));
    ref.invalidateSelf();
  }

  void updateTransaction({
    required String? id,
    required String? transactionCategoryId,
    required String? accountId,
    required String? date,
    required int? amount,
    required String? description,
    required String? type,
    required String? category,
    required String? account,
  }) async {
    await db!.updateTransaction(Transactionn(
        id: id,
        transactionCategoryId: transactionCategoryId,
        accountId: accountId,
        date: date,
        amount: amount,
        description: description,
        type: type,
        category: category,
        account: account));
    ref.invalidateSelf();
  }

  void deleteTransaction({required String transactionId}) async {
    await db!.deleteTransaction(transactionId);
    ref.invalidateSelf();
  }

  Set<Object> getGroupedTransactionsByDate(List<Transactionn> transactions) {
    final Set<Object> items = {};

    for (Transactionn transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.date!);
      DateTime parsedTransactionDate = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
      items.add(parsedTransactionDate);
      items.add(transaction);
    }

    return items;
  }
}
