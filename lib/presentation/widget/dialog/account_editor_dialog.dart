import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/notifier/account/account_notifier.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountEditor extends ConsumerWidget {
  const AccountEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Account> accounts = ref.watch(accountProvider).value!;
    return AlertDialog(
      title: const Text('Account Editor', style: TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(accounts.length, (index) {
            Account account = accounts[index];
            return ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(account.name!),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => DialogService.pushEditAccountDialog(context, account),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => DialogService.pushAddAccountDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add account'),
          ),
        ],
      ),
    );
  }
}

class EditAccountDialog extends ConsumerStatefulWidget {
  final Account account;
  const EditAccountDialog({required this.account, super.key});

  @override
  ConsumerState<EditAccountDialog> createState() => EditAccountDialogState();
}

class EditAccountDialogState extends ConsumerState<EditAccountDialog> {
  final TextEditingController newAccountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Edit `${widget.account.name}` account', style: const TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: newAccountNameController,
            maxLength: 15,
            decoration: const InputDecoration(labelText: 'Name'),
            autovalidateMode: AutovalidateMode.always,
            onChanged: (String? value) => setState(() {}),
            validator: (String? value) => value == '' ? 'Enter a new name' : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: newAccountNameController.text.isEmpty
                ? null
                : () {
                    ref.read(accountProvider.notifier).updateAccount(
                          accountId: widget.account.id!,
                          newName: newAccountNameController.value.text,
                        );
                    pushGlobalSnackbar(message: 'Account successfully edited');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
            child: const Text('Apply')),
      ],
    );
  }
}

class AddAccountDialog extends ConsumerStatefulWidget {
  const AddAccountDialog({super.key});

  @override
  ConsumerState<AddAccountDialog> createState() => AddAccountDialogState();
}

class AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final TextEditingController accountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new account', style: TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: accountNameController,
            maxLength: 15,
            decoration: const InputDecoration(labelText: 'Name'),
            autovalidateMode: AutovalidateMode.always,
            onChanged: (String? value) => setState(() {}),
            validator: (String? value) => value == '' ? 'Enter a name' : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: accountNameController.text.isEmpty
                ? null
                : () {
                    showDialog(
                        barrierColor: Colors.black54,
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AddAccountConfirmationDialog(
                            name: accountNameController.value.text));
                  },
            child: const Text('Add')),
      ],
    );
  }
}

class AddAccountConfirmationDialog extends ConsumerWidget {
  final String name;
  const AddAccountConfirmationDialog({required this.name, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Add `$name` account ?', style: const TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(24),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'WARNING! Account that have been added cannot be deleted further. Do you want to proceed?')
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              ref.read(accountProvider.notifier).addAccount(name: name);
              pushGlobalSnackbar(message: 'Account added');
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Proceed')),
      ],
    );
  }
}
