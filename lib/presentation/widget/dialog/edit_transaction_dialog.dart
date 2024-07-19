import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localCachedTransactionCategoryIdProvider =
    StateProvider<String>((ref) => ref.read(transactionCategoryProvider).value![0].id!);
final localCachedAccountIdProvider =
    StateProvider<String>((ref) => ref.read(accountProvider).value![0].id!);
final localAmountFormattedPreviewProvider = StateProvider<String>((ref) => '0');

class EditTransactionDialog extends ConsumerStatefulWidget {
  final Transactionn transaction;
  const EditTransactionDialog({required this.transaction, super.key});

  @override
  ConsumerState<EditTransactionDialog> createState() => EditTransactionDialogState();
}

class EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  late String id;
  late TextEditingController amountTextController;
  late String date;
  late TextEditingController descriptionTextController;
  late String transactionCategoryId;
  late String accountId;
  late String type;

  @override
  void initState() {
    super.initState();
    id = widget.transaction.id!;
    amountTextController = TextEditingController(text: widget.transaction.amount!.toString());
    date = widget.transaction.date!;
    descriptionTextController = TextEditingController(text: widget.transaction.description);
    transactionCategoryId = widget.transaction.transactionCategoryId!;
    accountId = widget.transaction.accountId!;
    type = widget.transaction.type!;
  }

  @override
  Widget build(BuildContext context) {
    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value!;
    List<Account> accounts = ref.watch(accountProvider).value!;

    return Dialog.fullscreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Edit Transaction'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: Theme.of(context).dialogBackgroundColor,
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount Preview
                Center(
                  child: Text(
                    currencyFormat(amountTextController.text == '' ? '0' : amountTextController.text, type),
                    style: TextStyle(
                        color: type == TransactionConst.income ? Colors.green : Colors.red),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Income expense
                Center(
                  child: SegmentedButton(
                    segments: const [
                      ButtonSegment(value: TransactionConst.income, label: Text('Income')),
                      ButtonSegment(value: TransactionConst.expense, label: Text('Expense'))
                    ],
                    selected: {type},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        type = newSelection.first;
                      });
                    },
                  ),
                ),
                // Amount Input
                TextFormField(
                  controller: amountTextController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.always,
                  maxLength: 18,
                  decoration: const InputDecoration(
                    hintText: 'Example: 125000',
                    labelText: 'Amount',
                  ),
                  onChanged: (String? value) {
                    setState(() {});
                  },
                  validator: (String? value) {
                    return int.tryParse(value!) == null ? 'Please enter a valid value' : null;
                  },
                ),
                // Description Input
                TextFormField(
                  maxLength: 20,
                  controller: descriptionTextController,
                  decoration: const InputDecoration(
                      hintText: 'Example: transfer, eat, ice cream', labelText: 'Description'),
                ),
                // Account dropdown
                DropdownMenu<String>(
                  width: 200,
                  initialSelection: accountId,
                  requestFocusOnTap: false,
                  label: const Text('Account', style: TextStyle(fontSize: 18)),
                  inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints.tight(const Size.fromHeight(55)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                  onSelected: (String? value) => setState(() => accountId = value!),
                  dropdownMenuEntries: List.generate(accounts.length, (index) {
                    Account account = accounts[index];
                    return DropdownMenuEntry(
                      value: account.id!,
                      label: account.name!,
                    );
                  }),
                ),
                // Category dropdown
                const SizedBox(height: 18),
                DropdownMenu<String>(
                  width: 200,
                  initialSelection: transactionCategoryId,
                  requestFocusOnTap: false,
                  label: const Text('Category', style: TextStyle(fontSize: 18)),
                  inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints.tight(const Size.fromHeight(55)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                  onSelected: (String? value) =>
                      setState(() => transactionCategoryId = value!),
                  dropdownMenuEntries: List.generate(transactionCategories.length, (index) {
                    TranscactionCategory transactionCategory = transactionCategories[index];
                    return DropdownMenuEntry(
                      value: transactionCategory.id!,
                      label: transactionCategory.name!,
                    );
                  }),
                ),
                // Hint
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Add new `Account` or new `Category` in Settings',
                  style: TextStyle(fontSize: 12),
                ),
                // Save
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    onPressed: int.tryParse(amountTextController.text) == null
                        ? null
                        : () {
                            ref.read(transactionProvider.notifier).updateTransaction(
                                  id: id,
                                  transactionCategoryId: transactionCategoryId,
                                  accountId: accountId,
                                  date: date,
                                  amount: int.tryParse(amountTextController.text),
                                  description: descriptionTextController.text,
                                  type: type,
                                  category: '',
                                  account: '',
                                );
                            pushGlobalSnackbar(message: 'Transaction successfully edited');
                            Navigator.pop(context);
                          },
                    child: Text('EDIT',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).appBarTheme.titleTextStyle!.fontSize! - 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
