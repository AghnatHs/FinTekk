import 'package:fl_chart/fl_chart.dart';
import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/report_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/notifier/report/report_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/row/report_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => ReportPageState();
}

class ReportPageState extends ConsumerState<ReportPage> {
  final selectMonthScrollController = ScrollController();
  final bodyScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Set<DateTime> reportMonths = ref.watch(reportMonthsListProvider).toList().reversed.toSet();
    DateTime reportSelectedMonth = ref.watch(reportSelectedMonthProvider);
    String reportSelectedTransactionType = ref.watch(reportSelectedTransactionTypeProvider);
    ReportByMonthByType reportByMonthType = ref.watch(reportByMonthByTypeProvider);
    Map<String, int> categoryBalanceMap = reportByMonthType.getCategoryBalance();

    ReportByMonth reportByMonth = ref.watch(reportByMonthProvider);

    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value!;

    return ref.watch(transactionProvider).value!.isEmpty
        ? const Center(
            child: Text('No Transactions'),
          )
        : Column(
            children: [
              // Select a month list view
              SizedBox(
                height: 50,
                child: Scrollbar(
                  controller: selectMonthScrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: selectMonthScrollController,
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      reportMonths.length,
                      (index) {
                        DateTime monthOfIndex = reportMonths.elementAt(index);
                        String parsedReportMonth = DateFormat('MMM y').format(monthOfIndex);

                        return InkWell(
                          onTap: () {
                            ref
                                .read(reportSelectedMonthProvider.notifier)
                                .update((state) => monthOfIndex);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.all(5),
                            width: 100,
                            color: reportMonths.elementAt(index) == reportSelectedMonth
                                ? ColorConst.defaultAppColor
                                : null,
                            child: Center(
                                child: Text(
                              parsedReportMonth,
                              style: TextStyle(
                                  color: reportMonths.elementAt(index) == reportSelectedMonth
                                      ? Colors.white
                                      : null),
                            )),
                          ),
                        );
                      },
                    ).reversed.toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 5),
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                        value: TransactionConst.income,
                        label: Text('Income'),
                        icon: Icon(null)),
                    ButtonSegment(
                        value: TransactionConst.expense,
                        label: Text('Expense'),
                        icon: Icon(null)),
                  ],
                  selected: {reportSelectedTransactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(
                      () {
                        ref
                            .read(reportSelectedTransactionTypeProvider.notifier)
                            .update((state) => newSelection.first);
                      },
                    );
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                    iconSize: MaterialStateProperty.all(0),
                  ),
                ),
              ),
              // [Body] piechart, report details
              Expanded(
                child: Scrollbar(
                  controller: bodyScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: bodyScrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // piechart
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.fromLTRB(3, 5, 3, 0),
                          child: Column(
                            children: [
                              // pie chart
                              AspectRatio(
                                aspectRatio: 1,
                                child: Column(
                                  children: [
                                    categoryBalanceMap.keys.isEmpty
                                        ? const Expanded(
                                            child: Center(child: Text('No Transactions Data')))
                                        : Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: PieChart(
                                                PieChartData(
                                                  sections: List.generate(
                                                    categoryBalanceMap.keys.length,
                                                    (index) {
                                                      String category = categoryBalanceMap.keys
                                                          .toList()[index];
                                                      double value =
                                                          categoryBalanceMap[category]!
                                                              .toDouble();
                                                      return PieChartSectionData(
                                                          title: category,
                                                          value: value,
                                                          radius: 50,
                                                          color: Color(transactionCategories
                                                              .where(
                                                                  (e) => e.name! == category)
                                                              .first
                                                              .color!),
                                                          titleStyle: const TextStyle(
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                              backgroundColor:
                                                                  Colors.black54));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // report
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('MMMM y').format(reportByMonth.monthYear)} Report',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                ReportRow(
                                    title: 'Income',
                                    data: currencyFormat(
                                        reportByMonth.getTotalIncome().toString())),
                                ReportRow(
                                  title: 'Expense',
                                  data: currencyFormat(
                                      reportByMonth.getTotalExpense().toString()),
                                ),
                                ReportRow(
                                  title: 'Average expense per day',
                                  data: currencyFormat(
                                      reportByMonth.getAverageDailyExpenses().toString(),
                                      TransactionConst.expense),
                                ),
                                const Divider(),
                                ReportRow(
                                  title: 'Summary',
                                  data: currencyFormat(
                                      reportByMonth.getTotalSummary().toString()),
                                  dataStyle: TextStyle(
                                    color: reportByMonth.getTotalSummary() >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // income details
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '$reportSelectedTransactionType Details (by category)',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                categoryBalanceMap.keys.isEmpty
                                    ? const Text('No Transactions Data')
                                    : const Stack(),
                                ...List.generate(
                                  categoryBalanceMap.keys.length,
                                  (index) {
                                    String category = categoryBalanceMap.keys.toList()[index];
                                    int value = categoryBalanceMap[category]!.toInt();
                                    return ReportRow(
                                      title: category,
                                      data: currencyFormat(
                                          value.toString(), reportSelectedTransactionType),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
