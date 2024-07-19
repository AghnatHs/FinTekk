import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/account_editor_dialog.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/category_editor_dialog.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/edit_transaction_dialog.dart';
import 'package:fl_finance_mngt/presentation/widget/dialog/input_transaction_dialog.dart';
import 'package:flutter/material.dart';

class DialogService {
  // TRANSACTION
  static pushInputTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) => const InputTransactionDialog(),
    );
  }

  static pushEditTransactionDialog(BuildContext context, Transactionn transaction) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) => EditTransactionDialog(
        transaction: transaction,
      ),
    );
  }

  // ACCOUNT
  static pushAccountEditor(BuildContext context) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => const AccountEditor());
  }

  static pushEditAccountDialog(BuildContext context, Account account) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => EditAccountDialog(account: account));
  }

  static pushAddAccountDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => const AddAccountDialog());
  }

  // CATEGORY
  static pushCategoryEditor(BuildContext context) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => const CategoryEditor());
  }

  static pushEditCategoryDialog(BuildContext context, TranscactionCategory transcactionCategory) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => EditCategoryDialog(category: transcactionCategory));
  }

   static pushAddCategoryDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        builder: (BuildContext context) => const AddCategoryDialog());
  }

}
