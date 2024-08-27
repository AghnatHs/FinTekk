import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:flutter/material.dart';

// contains a list of transaction that occur at selected month
class ReportByMonth {
  final DateTime monthYear;
  final List<Transactionn> transactions;
  ReportByMonth({required this.monthYear, required this.transactions});

  int getTotalIncome() {
    int income = 0;
    for (Transactionn transaction in transactions) {
      income = transaction.type == TransactionConst.income
          ? income + transaction.amount!
          : income + 0;
    }

    return income;
  }

  int getTotalExpense() {
    int expense = 0;
    for (Transactionn transaction in transactions) {
      expense = transaction.type == TransactionConst.expense
          ? expense + transaction.amount!
          : expense + 0;
    }

    return expense * -1;
  }

  int getTotalSummary() => getTotalIncome() + getTotalExpense();

  int getAverageDailyExpenses() =>
      getTotalExpense() ~/ DateUtils.getDaysInMonth(monthYear.year, monthYear.month);
}

// contains a list of transaction that occur at selected month and selected transaction type
class ReportByMonthByType {
  final DateTime monthYear;
  final String type;
  final List<Transactionn> transactions;
  ReportByMonthByType(
      {required this.monthYear, required this.type, required this.transactions});

  // {"category": balance in that month}
  Map<String, int> getCategoryBalance() {
    final Map<String, int> maps = {};

    for (Transactionn transaction in transactions) {
      int amount = transaction.amount!;
      maps.update(
        transaction.category!,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    final sortedMaps = maps.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    Map<String, int> newMaps = {for (var entry in sortedMaps) entry.key: entry.value};

    return newMaps;
  }
}