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

class ReportPageState extends ConsumerState<ReportPage> with TickerProviderStateMixin {
  final selectMonthScrollController = ScrollController();
  final bodyScrollController = ScrollController();


  @override
  void dispose() {
    selectMonthScrollController.dispose();
    bodyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<DateTime> reportMonths = ref.watch(reportMonthsListProvider).toList().reversed.toSet();
    DateTime reportSelectedMonth = ref.watch(reportSelectedMonthProvider);
    String reportSelectedTransactionType = ref.watch(reportSelectedTransactionTypeProvider);
    ReportByMonthByType reportByMonthType = ref.watch(reportByMonthByTypeProvider);
    Map<String, int> categoryBalanceMap = reportByMonthType.getCategoryBalance();

    ReportByMonth reportByMonth = ref.watch(reportByMonthProvider);

    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value ?? [];

    return ref.watch(transactionProvider).value!.isEmpty
        ? _buildEmptyState()
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorConst.surfaceLight,
                  ColorConst.surfaceLight.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: ListView(
              children: [
                _buildMonthSelector(reportMonths, reportSelectedMonth),
                _buildTransactionTypeSelector(reportSelectedTransactionType),
                Expanded(
                  child: _buildBodyContent(
                    categoryBalanceMap,
                    reportByMonth,
                    reportSelectedTransactionType,
                    transactionCategories,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(UIConst.spacingXL),
            decoration: BoxDecoration(
              color: ColorConst.surfaceLight,
              borderRadius: BorderRadius.circular(UIConst.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: ColorConst.textSecondary,
                ),
                const SizedBox(height: UIConst.spacingM),
                Text(
                  'No Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: ColorConst.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: UIConst.spacingS),
                Text(
                  'Add some transactions to see your reports',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ColorConst.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(Set<DateTime> reportMonths, DateTime reportSelectedMonth) {
    return Container(
      margin: const EdgeInsets.all(UIConst.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConst.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConst.spacingM,
              UIConst.spacingM,
              UIConst.spacingM,
              UIConst.spacingS,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: ColorConst.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: UIConst.spacingS),
                Text(
                  'Select Month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorConst.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Scrollbar(
              controller: selectMonthScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: selectMonthScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: UIConst.spacingM),
                itemCount: reportMonths.length,
                itemBuilder: (context, index) {
                  DateTime monthOfIndex = reportMonths.elementAt(index);
                  String parsedReportMonth = DateFormat('MMM y').format(monthOfIndex);
                  bool isSelected = monthOfIndex == reportSelectedMonth;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.only(right: UIConst.spacingS, bottom: UIConst.spacingS),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(reportSelectedMonthProvider.notifier)
                              .update((state) => monthOfIndex);
                        },
                        borderRadius: BorderRadius.circular(UIConst.radiusM),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConst.spacingM,
                            vertical: UIConst.spacingS,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      ColorConst.primaryGreen,
                                      ColorConst.primaryGreenLight,
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : ColorConst.surfaceLight,
                            borderRadius: BorderRadius.circular(UIConst.radiusM),
                            border: Border.all(
                              color: isSelected
                                  ? ColorConst.primaryGreen
                                  : ColorConst.neutralGray.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: ColorConst.primaryGreen.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              parsedReportMonth,
                              style: TextStyle(
                                color: isSelected ? Colors.white : ColorConst.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector(String reportSelectedTransactionType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConst.spacingM),
      padding: const EdgeInsets.all(UIConst.spacingXS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConst.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: TransactionConst.income,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: reportSelectedTransactionType == TransactionConst.income
                      ? Colors.white
                      : ColorConst.incomeGreen,
                ),
                const SizedBox(width: UIConst.spacingXS),
                const Text('Income'),
              ],
            ),
          ),
          ButtonSegment(
            value: TransactionConst.expense,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_down,
                  size: 18,
                  color: reportSelectedTransactionType == TransactionConst.expense
                      ? Colors.white
                      : ColorConst.expenseRed,
                ),
                const SizedBox(width: UIConst.spacingXS),
                const Text('Expense'),
              ],
            ),
          ),
        ],
        selected: {reportSelectedTransactionType},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            ref
                .read(reportSelectedTransactionTypeProvider.notifier)
                .update((state) => newSelection.first);
          });
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return reportSelectedTransactionType == TransactionConst.income
                  ? ColorConst.incomeGreen
                  : ColorConst.expenseRed;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return ColorConst.textPrimary;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide.none;
            }
            return BorderSide(
              color: ColorConst.neutralGray.withValues(alpha: 0.3),
              width: 1,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    Map<String, int> categoryBalanceMap,
    ReportByMonth reportByMonth,
    String reportSelectedTransactionType,
    List<TranscactionCategory> transactionCategories,
  ) {
    return Scrollbar(
      controller: bodyScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: bodyScrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          UIConst.spacingM,
          UIConst.spacingM,
          UIConst.spacingM,
          UIConst.spacingXL,
        ),
        child: Column(
          children: [
            _buildPieChartCard(categoryBalanceMap, transactionCategories),
            const SizedBox(height: UIConst.spacingL),
            _buildSummaryCard(reportByMonth),
            const SizedBox(height: UIConst.spacingL),
            _buildCategoryDetailsCard(
              categoryBalanceMap,
              reportSelectedTransactionType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(
    Map<String, int> categoryBalanceMap,
    List<TranscactionCategory> transactionCategories,
  ) {
    return Container(
      padding: const EdgeInsets.all(UIConst.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: ColorConst.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorConst.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConst.spacingL),
          AspectRatio(
            aspectRatio: 1.2,
            child: categoryBalanceMap.keys.isEmpty
                ? _buildEmptyChart()
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: List.generate(
                        categoryBalanceMap.keys.length,
                        (index) {
                          String category = categoryBalanceMap.keys.toList()[index];
                          double value = categoryBalanceMap[category]!.toDouble();
                          double percentage =
                              value / categoryBalanceMap.values.reduce((a, b) => a + b) * 100;

                          return PieChartSectionData(
                            title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                            value: value,
                            radius: 80,
                            color: Color(
                              (transactionCategories
                                  .firstWhere(
                                    (e) => e.name == category,
                                    orElse: () => TranscactionCategory(
                                      color: 0,
                                      id: '',
                                      name: 'Unknown',
                                    ),
                                  )
                                  .color)!,
                            ),
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          if (categoryBalanceMap.keys.isNotEmpty) ...[
            const SizedBox(height: UIConst.spacingL),
            _buildLegend(categoryBalanceMap, transactionCategories),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.surfaceLight,
        borderRadius: BorderRadius.circular(UIConst.radiusM),
        border: Border.all(
          color: ColorConst.neutralGray.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: ColorConst.textSecondary,
            ),
            const SizedBox(height: UIConst.spacingM),
            Text(
              'No Data Available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorConst.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
    Map<String, int> categoryBalanceMap,
    List<TranscactionCategory> transactionCategories,
  ) {
    return Wrap(
      spacing: UIConst.spacingM,
      runSpacing: UIConst.spacingS,
      children: categoryBalanceMap.entries.map((entry) {
        String category = entry.key;
        Color categoryColor = Color(
          (transactionCategories
              .firstWhere(
                (e) => e.name == category,
                orElse: () => TranscactionCategory(
                  color: 0,
                  id: '',
                  name: 'Unknown',
                ),
              )
              .color)!,
        );

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingM,
            vertical: UIConst.spacingS,
          ),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(UIConst.radiusL),
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: UIConst.spacingS),
              Text(
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ColorConst.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(ReportByMonth reportByMonth) {
    return Container(
      padding: const EdgeInsets.all(UIConst.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: ColorConst.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: const Icon(
                  Icons.summarize,
                  color: ColorConst.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Expanded(
                child: Text(
                  '${DateFormat('MMMM y').format(reportByMonth.monthYear)} Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ColorConst.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConst.spacingL),
          _buildSummaryItem(
            icon: Icons.trending_up,
            title: 'Total Income',
            value: currencyFormat(reportByMonth.getTotalIncome().toString()),
            color: ColorConst.incomeGreen,
          ),
          const SizedBox(height: UIConst.spacingM),
          _buildSummaryItem(
            icon: Icons.trending_down,
            title: 'Total Expense',
            value: currencyFormat(reportByMonth.getTotalExpense().toString()),
            color: ColorConst.expenseRed,
          ),
          const SizedBox(height: UIConst.spacingM),
          _buildSummaryItem(
            icon: Icons.calendar_today,
            title: 'Avg Daily Expense',
            value: currencyFormat(
              reportByMonth.getAverageDailyExpenses().toString(),
              TransactionConst.expense,
            ),
            color: ColorConst.accentOrange,
          ),
          const Divider(height: UIConst.spacingXL),
          _buildSummaryItem(
            icon: Icons.account_balance_wallet,
            title: 'Net Balance',
            value: currencyFormat(reportByMonth.getTotalSummary().toString()),
            color: reportByMonth.getTotalSummary() >= 0
                ? ColorConst.incomeGreen
                : ColorConst.expenseRed,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isHighlighted ? UIConst.spacingM : UIConst.spacingS),
      decoration: isHighlighted
          ? BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConst.radiusM),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConst.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: UIConst.spacingM),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ColorConst.textPrimary,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailsCard(
    Map<String, int> categoryBalanceMap,
    String reportSelectedTransactionType,
  ) {
    return Container(
      padding: const EdgeInsets.all(UIConst.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: ColorConst.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: const Icon(
                  Icons.category,
                  color: ColorConst.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Expanded(
                child: Text(
                  '$reportSelectedTransactionType by Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ColorConst.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConst.spacingL),
          categoryBalanceMap.keys.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(UIConst.spacingXL),
                  decoration: BoxDecoration(
                    color: ColorConst.surfaceLight,
                    borderRadius: BorderRadius.circular(UIConst.radiusM),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: ColorConst.textSecondary,
                        ),
                        const SizedBox(height: UIConst.spacingM),
                        Text(
                          'No Category Data',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: ColorConst.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: categoryBalanceMap.entries.map((entry) {
                    String category = entry.key;
                    int value = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: UIConst.spacingS),
                      child: ReportRow(
                        title: category,
                        data: currencyFormat(value.toString(), reportSelectedTransactionType),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
