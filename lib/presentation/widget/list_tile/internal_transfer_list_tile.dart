import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/general_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO: Create Edit Internal Transfer
class InternalTransferListTile extends ConsumerWidget {
  final InternalTransfer internalTransfer;
  final bool isShowingOption;
  const InternalTransferListTile(
      {required this.internalTransfer, this.isShowingOption = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String idTruncated =
        'id: ${internalTransfer.linkedTransferId.split('-')[3]}${internalTransfer.linkedTransferId.split('-')[4]}';
    return Stack(
      children: [
        Card(
          color: Colors.white70,
          child: ListTile(
            minVerticalPadding: 1,
            visualDensity: VisualDensity.compact,
            title: RichText(
              text: TextSpan(
                text:
                    currencyFormat(internalTransfer.amount.toString(), internalTransfer.type),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                      color: internalTransfer.type == TransactionConst.income
                          ? Colors.green
                          : Colors.red,
                    ),
                children: [
                  TextSpan(
                    text: internalTransfer.type == TransactionConst.income
                        ? ' to ${internalTransfer.accountName}'
                        : ' from ${internalTransfer.accountName}',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).shadowColor),
                  )
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('HH:mm').format(DateTime.parse(internalTransfer.date))} [INTERNAL TRANSFER]',
                  style:
                      Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black54),
                ),
                Text(
                  idTruncated,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.black54, fontSize: 14),
                )
              ],
            ),
            trailing: isShowingOption
                ? Wrap(
                    spacing: 5,
                    children: [
                      InkWell(
                        onTap: () async {
                          bool isConfirm = await showDialog(
                            context: context,
                            builder: (_) => GeneralConfimationDialog(
                                title: 'Delete Internal Transfer?',
                                content:
                                    'Are you sure you want to delete this Internal Transfer? its linked internal transfer will also be deleted\n$idTruncated'),
                          );
                          if (isConfirm) {
                            ref
                                .read(internalTransferProvider.notifier)
                                .deleteInternalTransferLinked(
                                    linkedTransferId: internalTransfer.linkedTransferId);
                            pushGlobalSnackbar(message: 'Internal Transfer deleted');
                          }
                        },
                        child: const Icon(Icons.delete, size: 30, color: Colors.redAccent),
                      )
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
