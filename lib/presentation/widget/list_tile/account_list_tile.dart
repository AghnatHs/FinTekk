import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountListTile extends ConsumerWidget {
  final Account account;
  final int balance;
  const AccountListTile({required this.account, required this.balance, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
      child: Row(
        children: [
          Expanded(
              child: Text(
            account.name ?? 'Null',
            style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
          )),
          Expanded(
              child: Text(
            currencyFormat(balance.toString()),
            textAlign: TextAlign.right,
            style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
          )),
        ],
      ),
    );
  }
}
