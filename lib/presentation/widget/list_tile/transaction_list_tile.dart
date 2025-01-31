import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/general_confirmation_dialog.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends ConsumerWidget {
  final Transactionn transaction;
  final bool isShowingOption;
  const TransactionListTile(
      {required this.transaction, this.isShowingOption = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Card(
          child: ListTile(
            minVerticalPadding: 1,
            visualDensity: VisualDensity.compact,
            title: RichText(
              text: TextSpan(
                text: currencyFormat(transaction.amount.toString(), transaction.type),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                      color: transaction.type == TransactionConst.income
                          ? Colors.green
                          : Colors.red,
                    ),
                children: [
                  TextSpan(
                    text: transaction.type == TransactionConst.income
                        ? ' to ${transaction.account}'
                        : ' from ${transaction.account}',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).shadowColor),
                  )
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                transaction.description != ''
                    ? Text(
                        '"${transaction.description!}"',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : const Stack(),
                RichText(
                  text: TextSpan(
                      text: 'Category: ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: transaction.category,
                        )
                      ]),
                ),
                Text(
                  DateFormat('HH:mm').format(DateTime.parse(transaction.date)),
                  style:
                      Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black54),
                ),
              ],
            ),
            trailing: isShowingOption
                ? Wrap(
                    spacing: 5,
                    children: [
                      InkWell(
                        onTap: () =>
                            DialogService.pushEditTransactionDialog(context, transaction),
                        child: const Icon(Icons.edit, size: 30),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          bool isConfirm = await showDialog(
                            context: context,
                            builder: (_) => GeneralConfimationDialog(
                                title: 'Delete Transaction?',
                                content:
                                    'Are you sure you want to delete this transaction?\n${transaction.amount} - ${transaction.category} - ${transaction.type}\n${transaction.description}'),
                          );
                          if (isConfirm) {
                            ref
                                .read(transactionProvider.notifier)
                                .deleteTransaction(transactionId: transaction.id);
                            pushGlobalSnackbar(message: 'Transaction deleted');
                          }
                        },
                        child: const Icon(Icons.delete, size: 30, color: Colors.redAccent),
                      )
                    ],
                  )
                : null,
          ),
        ),
        Positioned(
          left: 4,
          top: 32,
          child: Container(
            width: 12,
            height: 30,
            decoration: BoxDecoration(color: Color(transaction.categoryColor)),
          ),
        ),
      ],
    );
  }
}
