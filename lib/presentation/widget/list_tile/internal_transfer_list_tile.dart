import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/general_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO: Create Edit Internal Transfer
class InternalTransferListTile extends ConsumerStatefulWidget {
  final InternalTransfer internalTransfer;
  final bool isShowingOption;
  const InternalTransferListTile(
      {required this.internalTransfer, this.isShowingOption = false, super.key});

  @override
  ConsumerState<InternalTransferListTile> createState() => _InternalTransferListTileState();
}

class _InternalTransferListTileState extends ConsumerState<InternalTransferListTile>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = widget.internalTransfer.type == TransactionConst.income;
    final transferColor = isIncome ? ColorConst.incomeGreen : ColorConst.expenseRed;
    String idTruncated =
        'id: ${widget.internalTransfer.linkedTransferId.split('-')[3]}${widget.internalTransfer.linkedTransferId.split('-')[4]}';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConst.spacingS,
        vertical: UIConst.spacingXS,
      ),
      child: Card(
        elevation: UIConst.elevationLow,
        shadowColor: transferColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConst.radiusL),
          side: BorderSide(
            color: transferColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UIConst.radiusL),
          child: Stack(
            children: [
              // Transfer type color indicator
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: transferColor,
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
                      transferColor.withValues(alpha: 0.03),
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
                      color: transferColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(UIConst.radiusM),
                      border: Border.all(
                        color: transferColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: transferColor,
                      size: 28,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount
                      Text(
                        currencyFormat(widget.internalTransfer.amount.toString(),
                            widget.internalTransfer.type),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: transferColor,
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
                              '${isIncome ? "to" : "from"} ${widget.internalTransfer.accountName}',
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
                        // Transfer type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConst.spacingS,
                            vertical: UIConst.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConst.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(UIConst.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.swap_horiz_rounded,
                                size: 12,
                                color: ColorConst.accentBlue,
                              ),
                              const SizedBox(width: UIConst.spacingXS),
                              Expanded(
                                child: Text(
                                  'INTERNAL TRANSFER',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ColorConst.accentBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: UIConst.spacingS),

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
                                  .format(DateTime.parse(widget.internalTransfer.date)),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: ColorConst.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.tag_rounded,
                              size: 12,
                              color: ColorConst.textSecondary,
                            ),
                            const SizedBox(width: UIConst.spacingXS),
                            Expanded(
                              child: Text(
                                idTruncated,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: ColorConst.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: widget.isShowingOption
                      ? _buildActionButtons(context, theme, transferColor, idTruncated)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ThemeData theme, Color transferColor, String idTruncated) {
    return AnimatedSlide(
      offset: Offset(widget.isShowingOption ? 0.0 : 1.0, 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    title: 'Delete Internal Transfer?',
                    content:
                        'Are you sure you want to delete this Internal Transfer? Its linked internal transfer will also be deleted.\n\n'
                        '${currencyFormat(widget.internalTransfer.amount.toString(), widget.internalTransfer.type)}\n'
                        '${widget.internalTransfer.accountName} • ${widget.internalTransfer.type}\n'
                        '$idTruncated',
                  ),
                );
                if (isConfirm) {
                  ref.read(internalTransferProvider.notifier).deleteInternalTransferLinked(
                      linkedTransferId: widget.internalTransfer.linkedTransferId);
                  pushGlobalSnackbar(message: 'Internal Transfer deleted successfully');
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
