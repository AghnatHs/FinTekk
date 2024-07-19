import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/model/report_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportMonthsListProvider =
    StateNotifierProvider<ReportMonthsListNotifier, Set<DateTime>>((ref) {
  try {
    final List<Transactionn> transactions = ref.watch(transactionProvider).value!;
    final Set<DateTime> state = {};

    for (Transactionn transaction in transactions) {
      DateTime parsedDate = DateTime.parse(transaction.date!);
      DateTime formattedParsedDate = DateTime(parsedDate.year, parsedDate.month);
      state.add(formattedParsedDate);
    }

    return ReportMonthsListNotifier(state);
  } catch (e) {
    return ReportMonthsListNotifier({});
  }
});

final reportSelectedMonthProvider = StateProvider<DateTime>((ref) {
  try {
    return ref.watch(reportMonthsListProvider).elementAt(0);
  } catch (e) {
    // if there arent any transaction
    return DateTime.now();
  }
});

final reportSelectedTransactionTypeProvider =
    StateProvider<String>((ref) => TransactionConst.income);

final reportByMonthByTypeProvider = Provider<ReportByMonthByType>((ref) {
  final List<Transactionn> transactions = ref.watch(transactionProvider).value!;
  final DateTime reportSelectedMonth = ref.watch(reportSelectedMonthProvider);
  final String reportSelectedTransactionType =
      ref.watch(reportSelectedTransactionTypeProvider);
  final List<Transactionn> filteredTransactions = [];

  for (Transactionn transaction in transactions) {
    DateTime tDate = DateTime.parse(transaction.date!);
    int tDateYear = tDate.year;
    int tDateMonth = tDate.month;
    int rDateYear = reportSelectedMonth.year;
    int rDateMonth = reportSelectedMonth.month;
    String tType = transaction.type!;
    bool isSameDateByMonthAndYear = rDateYear == tDateYear && rDateMonth == tDateMonth;
    bool isSameType = tType == reportSelectedTransactionType;

    if (isSameDateByMonthAndYear && isSameType) filteredTransactions.add(transaction);
  }

  filteredTransactions.sort((a, b) => a.date!.compareTo(b.date!));
  return ReportByMonthByType(
    monthYear: reportSelectedMonth,
    type: reportSelectedTransactionType,
    transactions: filteredTransactions,
  );
});

final reportByMonthProvider = Provider<ReportByMonth>((ref) {
  final List<Transactionn> transactions = ref.watch(transactionProvider).value!;
  final DateTime reportSelectedMonth = ref.watch(reportSelectedMonthProvider);
  final List<Transactionn> filteredTransactions = [];

  for (Transactionn transaction in transactions) {
    DateTime tDate = DateTime.parse(transaction.date!);
    int tDateYear = tDate.year;
    int tDateMonth = tDate.month;
    int rDateYear = reportSelectedMonth.year;
    int rDateMonth = reportSelectedMonth.month;
    bool isSameDateByMonthAndYear = rDateYear == tDateYear && rDateMonth == tDateMonth;

    if (isSameDateByMonthAndYear) filteredTransactions.add(transaction);
  }

  filteredTransactions.sort((a, b) => a.date!.compareTo(b.date!));
  return ReportByMonth(monthYear: reportSelectedMonth, transactions: filteredTransactions);
});

class ReportMonthsListNotifier extends StateNotifier<Set<DateTime>> {
  ReportMonthsListNotifier(super.state);

  void setState({required Set<DateTime> newState}) {
    state = newState;
  }
}
