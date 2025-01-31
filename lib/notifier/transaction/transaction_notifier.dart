import 'dart:async';
import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/model/abstracts/abstract_transaction_model.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
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
      ..sort((a, b) => a.date.compareTo(b.date));

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
      required int categoryColor,
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
        categoryColor: categoryColor,
        account: account));
    ref.invalidateSelf();
  }

  void updateTransaction({
    required String id,
    required String transactionCategoryId,
    required String accountId,
    required String date,
    required int amount,
    required String? description,
    required String type,
    required String category,
    required int categoryColor,
    required String account,
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
        categoryColor: categoryColor,
        account: account));
    ref.invalidateSelf();
  }

  void deleteTransaction({required String transactionId}) async {
    await db!.deleteTransaction(transactionId);
    ref.invalidateSelf();
  }

  Set<Object> getGroupedTransactionsAndInternalTransfersByDate(
      List<Transactionn> transactions, List<InternalTransfer> internalTransfers) {
    final Set<Object> items = {};

    List<TransactionObject> mergedTransactionObjects = List.from(transactions)
      ..addAll(internalTransfers);
    mergedTransactionObjects.sort((a, b) => a.date.compareTo(b.date));
    mergedTransactionObjects =  mergedTransactionObjects.reversed.toList();

    for (TransactionObject transactionObj in mergedTransactionObjects) {
      DateTime transactionObjDate = DateTime.parse(transactionObj.date);
      DateTime parsedTransactionObjDate =
          DateTime(transactionObjDate.year, transactionObjDate.month, transactionObjDate.day);
      items.add(parsedTransactionObjDate);
      items.add(transactionObj);
    }
    return items;
  }

  Map<DateTime, int> getDailyTotalSummary(List<Transactionn> transactions) {
    final Map<DateTime, int> maps = {};

    for (Transactionn transaction in transactions) {
      DateTime tDate = DateTime.parse(transaction.date);
      DateTime tDateAsKey = DateTime(tDate.year, tDate.month, tDate.day);
      int tAmount = transaction.type == TransactionConst.income
          ? transaction.amount
          : transaction.amount * -1;

      maps.update(tDateAsKey, (value) => value + tAmount, ifAbsent: () => tAmount);
    }

    return maps;
  }
}
