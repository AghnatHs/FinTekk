import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/core/helper.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/notifier/internal_transfer/internal_transfer_notifier.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final localCachedTransactionCategoryIdProvider =
    StateProvider<String>((ref) => ref.read(transactionCategoryProvider).value![0].id!);
final localCachedSourceAccountIdProvider =
    StateProvider<String>((ref) => ref.read(accountProvider).value![0].id!);
final localCachedDestinationAccountIdProvider =
    StateProvider<String>((ref) => ref.read(accountProvider).value![1].id!);
final localAmountFormattedPreviewProvider = StateProvider<String>((ref) => '0');

class InputInternalTransferDialog extends ConsumerStatefulWidget {
  const InputInternalTransferDialog({super.key});

  @override
  ConsumerState<InputInternalTransferDialog> createState() =>
      InputInternalTransferDialogState();
}

class InputInternalTransferDialogState extends ConsumerState<InputInternalTransferDialog> {
  final TextEditingController amountTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Account> accounts = ref.watch(accountProvider).value!;
    String sourceAccountId = ref.watch(localCachedSourceAccountIdProvider);
    String destinationAccountId = ref.watch(localCachedDestinationAccountIdProvider);

    return Dialog.fullscreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add Internal Transfer'),
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
                    rawCurrencyFormat(
                        amountTextController.text == '' ? '0' : amountTextController.text),
                  ),
                ),
                const SizedBox(height: 5),
                // Amount Input
                TextFormField(
                  autofocus: true,
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
                const SizedBox(height: 12),
                // Source Account dropdown
                DropdownMenu<String>(
                  width: 200,
                  initialSelection: sourceAccountId,
                  requestFocusOnTap: false,
                  label: const Text('Source Account', style: TextStyle(fontSize: 18, color: Colors.red)),
                  inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints.tight(const Size.fromHeight(55)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                  onSelected: (String? value) => ref
                      .read(localCachedSourceAccountIdProvider.notifier)
                      .update((state) => value!),
                  dropdownMenuEntries: List.generate(accounts.length, (index) {
                    Account account = accounts[index];
                    return DropdownMenuEntry(
                      value: account.id!,
                      label: account.name!,
                    );
                  }),
                ),
                const SizedBox(height: 18),
                // Destination Account dropdown
                DropdownMenu<String>(
                  width: 200,
                  initialSelection: destinationAccountId,
                  requestFocusOnTap: false,
                  label: const Text('Destination Account', style: TextStyle(fontSize: 18, color: Colors.green)),
                  inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints.tight(const Size.fromHeight(55)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                  onSelected: (String? value) => ref
                      .read(localCachedDestinationAccountIdProvider.notifier)
                      .update((state) => value!),
                  dropdownMenuEntries: List.generate(accounts.length, (index) {
                    Account account = accounts[index];
                    return DropdownMenuEntry(
                      value: account.id!,
                      label: account.name!,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your internal transfers in \'home\'',
                  style: TextStyle(fontSize: 14),
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
                    onPressed: int.tryParse(amountTextController.text) == null ||
                            (sourceAccountId == destinationAccountId)
                        ? null
                        : () {
                            String linkedTransferId = const Uuid().v7();
                            // source
                            ref.read(internalTransferProvider.notifier).addInternalTransfer(
                                linkedTransferId: linkedTransferId,
                                accountId: sourceAccountId,
                                amount: int.tryParse(amountTextController.text)!,
                                type: TransactionConst.expense,
                                date: DateTime.now().toIso8601String());
                            // destination
                            ref.read(internalTransferProvider.notifier).addInternalTransfer(
                                linkedTransferId: linkedTransferId,
                                accountId: destinationAccountId,
                                amount: int.tryParse(amountTextController.text)!,
                                type: TransactionConst.income,
                                date: DateTime.now().toIso8601String());
                            pushGlobalSnackbar(message: 'Internal Transfer Added');
                            Navigator.pop(context);
                          },
                    child: Text('ADD',
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
