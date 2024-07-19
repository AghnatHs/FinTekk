import 'package:fl_chart/fl_chart.dart';
import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/report_model.dart';
import 'package:fl_finance_mngt/notifier/report/report_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
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
  final categoryBalanceScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Set<DateTime> reportMonths = ref.watch(reportMonthsListProvider).toList().reversed.toSet();
    String reportSelectedTranscationType = ref.watch(reportSelectedTransactionTypeProvider);
    ReportByMonthByType reportByMonthType = ref.watch(reportByMonthByTypeProvider);
    Map<String, int> categoryBalanceMap = reportByMonthType.getCategoryBalance();
    ReportByMonth reportByMonth = ref.watch(reportByMonthProvider);

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
                        DateTime reportSelectedMonth = reportMonths.elementAt(index);
                        String parsedReportMonth =
                            DateFormat('MMM y').format(reportSelectedMonth);

                        return InkWell(
                          onTap: () {
                            ref
                                .read(reportSelectedMonthProvider.notifier)
                                .update((state) => reportMonths.elementAt(index));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(4),
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
              // Segmented, piechart, details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        // Pie Chart
                        child: Column(
                          children: [
                            SegmentedButton(
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
                              selected: {reportSelectedTranscationType},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  ref
                                      .read(reportSelectedTransactionTypeProvider.notifier)
                                      .update((state) => newSelection.first);
                                });
                              },
                            ),
                            categoryBalanceMap.keys.isEmpty
                                ? const Expanded(
                                    child: Center(child: Text('No Transactions Data')))
                                : Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        centerSpaceRadius: 0,
                                        sections: List.generate(
                                          categoryBalanceMap.keys.length,
                                          (index) {
                                            String category =
                                                categoryBalanceMap.keys.toList()[index];
                                            double value =
                                                categoryBalanceMap[category]!.toDouble();
                                            return PieChartSectionData(
                                                title:
                                                    '$category \n${rawCurrencyFormat(value.toString())}',
                                                value: value,
                                                radius: 120,
                                                color: Theme.of(context).primaryColor,
                                                titleStyle: const TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      // Report Table
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${DateFormat('MMMM y').format(reportByMonth.monthYear)} Report',
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Income'),
                                  Text(currencyFormat(
                                      reportByMonth.getTotalIncome().toString()))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Expense'),
                                  Text(currencyFormat(
                                      reportByMonth.getTotalExpense().toString()))
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Summary'),
                                  Text(currencyFormat(
                                      reportByMonth.getTotalSummary().toString()))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      /* categoryBalanceMap.keys.isEmpty
                          ? const Expanded(
                              child: Center(child: Text('No Transactions Data')),
                            )
                          : Expanded(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: Scrollbar(
                                  controller: categoryBalanceScrollController,
                                  thumbVisibility: true,
                                  child: ListView(
                                    children:
                                        List.generate(categoryBalanceMap.keys.length, (index) {
                                      String category =
                                          categoryBalanceMap.keys.toList()[index];
                                      double value = categoryBalanceMap[category]!.toDouble();
                                      return Card(
                                        elevation: 3,
                                        color: Theme.of(context).primaryColor,
                                        child: ListTile(
                                          title: Text(category),
                                          subtitle: Text(currencyFormat(
                                              value.toInt().toString(),
                                              reportSelectedTranscationType)),
                                          titleTextStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          subtitleTextStyle:
                                              const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ) */
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
