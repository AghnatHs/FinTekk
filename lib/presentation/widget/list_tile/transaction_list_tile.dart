import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/general_confirmation_dialog.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends ConsumerStatefulWidget {
  final Transactionn transaction;
  final bool isShowingOption;
  const TransactionListTile({required this.transaction, this.isShowingOption = false, super.key});

  @override
  ConsumerState<TransactionListTile> createState() => _TransactionListTileState();
}

class _TransactionListTileState extends ConsumerState<TransactionListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = widget.transaction.type == TransactionConst.income;
    final transactionColor = isIncome ? ColorConst.incomeGreen : ColorConst.expenseRed;
    final categoryColor = Color(widget.transaction.categoryColor);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: UIConst.spacingS,
              vertical: UIConst.spacingXS,
            ),
            child: Card(
              elevation: UIConst.elevationLow,
              shadowColor: transactionColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConst.radiusL),
                side: BorderSide(
                  color: transactionColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UIConst.radiusL),
                child: Stack(
                  children: [
                    // Category color indicator
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: categoryColor.computeLuminance() > 0.5
                              ? categoryColor
                              : categoryColor.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(UIConst.radiusL),
                            bottomLeft: Radius.circular(UIConst.radiusL),
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            transactionColor.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: UIConst.spacingM,
                          vertical: UIConst.spacingS,
                        ),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: transactionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(UIConst.radiusM),
                            border: Border.all(
                              color: transactionColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            color: transactionColor,
                            size: 28,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount
                            Text(
                              currencyFormat(
                                  widget.transaction.amount.toString(), widget.transaction.type),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: transactionColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: UIConst.spacingXS),

                            // Account info
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 14,
                                  color: ColorConst.textSecondary,
                                ),
                                const SizedBox(width: UIConst.spacingXS),
                                Expanded(
                                  child: Text(
                                    '${isIncome ? "to" : "from"} ${widget.transaction.account}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: ColorConst.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: UIConst.spacingS),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              if (widget.transaction.description != null &&
                                  widget.transaction.description!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UIConst.spacingS,
                                    vertical: UIConst.spacingXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorConst.neutralGray.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(UIConst.radiusS),
                                  ),
                                  child: Text(
                                    '"${widget.transaction.description!}"',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: ColorConst.textPrimary,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: UIConst.spacingS),

                              // Category and time row
                              Row(
                                children: [
                                  // Category
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: categoryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: UIConst.spacingS),
                                        Expanded(
                                          child: Text(
                                            widget.transaction.category,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: ColorConst.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Time
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: ColorConst.textSecondary,
                                      ),
                                      const SizedBox(width: UIConst.spacingXS),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(DateTime.parse(widget.transaction.date)),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: ColorConst.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: widget.isShowingOption
                            ? _buildActionButtons(context, theme, transactionColor)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, Color transactionColor) {
    return AnimatedSlide(
      offset: Offset(widget.isShowingOption ? 0.0 : 1.0, 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit button
          Container(
            decoration: BoxDecoration(
              color: ColorConst.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                DialogService.pushEditTransactionDialog(context, widget.transaction);
              },
              icon: const Icon(Icons.edit_rounded),
              color: ColorConst.accentBlue,
              iconSize: 20,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(UIConst.spacingS),
                minimumSize: const Size(36, 36),
              ),
            ),
          ),

          const SizedBox(width: UIConst.spacingS),

          // Delete button
          Container(
            decoration: BoxDecoration(
              color: ColorConst.expenseRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
            child: IconButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                bool isConfirm = await showDialog(
                  context: context,
                  builder: (_) => GeneralConfimationDialog(
                    title: 'Delete Transaction?',
                    content: 'Are you sure you want to delete this transaction?\n\n'
                        '${currencyFormat(widget.transaction.amount.toString(), widget.transaction.type)}\n'
                        '${widget.transaction.category} • ${widget.transaction.type}\n'
                        '${widget.transaction.description ?? "No description"}',
                  ),
                );
                if (isConfirm) {
                  ref
                      .read(transactionProvider.notifier)
                      .deleteTransaction(transactionId: widget.transaction.id);
                  pushGlobalSnackbar(
                    message: 'Transaction deleted successfully',
                  );
                }
              },
              icon: const Icon(Icons.delete_rounded),
              color: ColorConst.expenseRed,
              iconSize: 20,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(UIConst.spacingS),
                minimumSize: const Size(36, 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
