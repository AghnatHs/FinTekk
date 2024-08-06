import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/notifier/transaction_category/transaction_category_notifier.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryEditor extends ConsumerWidget {
  const CategoryEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TranscactionCategory> transactionCategories =
        ref.watch(transactionCategoryProvider).value!;
    return AlertDialog(
      title: const Text('Category Editor', style: TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(transactionCategories.length, (index) {
            TranscactionCategory transactionCategory = transactionCategories[index];
            return ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(transactionCategory.name!),
              leading: Icon(
                Icons.circle,
                color: Color(transactionCategory.color!),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    DialogService.pushEditCategoryDialog(context, transactionCategory),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => DialogService.pushAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add category'),
          ),
        ],
      ),
    );
  }
}

class EditCategoryDialog extends ConsumerStatefulWidget {
  final TranscactionCategory category;
  const EditCategoryDialog({required this.category, super.key});

  @override
  ConsumerState<EditCategoryDialog> createState() => EditCategoryDialogState();
}

class EditCategoryDialogState extends ConsumerState<EditCategoryDialog> {
  final TextEditingController newCategoryNameController = TextEditingController(); //default
  late Color newColor;

  @override
  void initState() {
    super.initState();
    newColor = Color(widget.category.color!);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit `${widget.category.name}` category',
          style: const TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(18),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: newCategoryNameController,
                maxLength: 15,
                decoration: const InputDecoration(labelText: 'Name'),
                autovalidateMode: AutovalidateMode.always,
                onChanged: (String? value) => setState(() {}),
                validator: (String? value) => value == '' ? 'Enter a new name' : null,
              ),
              const SizedBox(height: 10),
              const Text(
                'Pick a Color',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              BlockPicker(
                pickerColor: newColor,
                onColorChanged: (color) => setState(() {
                  newColor = color;
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: newCategoryNameController.text.isEmpty
                ? null
                : () {
                    ref.read(transactionCategoryProvider.notifier).updateTransactionCategory(
                          transactionCategoryId: widget.category.id!,
                          newName: newCategoryNameController.text,
                          newColor: newColor.value,
                        );
                    pushGlobalSnackbar(message: 'Category successfully edited');
                    Navigator.pop(context);
                  },
            child: const Text('Apply')),
      ],
    );
  }
}

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => AddCategoryDialogState();
}

class AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final TextEditingController categoryNameController = TextEditingController();
  late Color colorPick;

  @override
  void initState() {
    super.initState();
    colorPick = Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new category', style: TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(18),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: categoryNameController,
                maxLength: 15,
                decoration: const InputDecoration(labelText: 'Name'),
                autovalidateMode: AutovalidateMode.always,
                onChanged: (String? value) => setState(() {}),
                validator: (String? value) => value == '' ? 'Enter a name' : null,
              ),
              const SizedBox(height: 10),
              const Text('Pick a color',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),
              BlockPicker(
                pickerColor: colorPick,
                onColorChanged: (color) => setState(() {
                  colorPick = color;
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: categoryNameController.text.isEmpty
                ? null
                : () {
                    showDialog(
                        barrierColor: Colors.black54,
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AddCategoryConfirmationDialog(
                              name: categoryNameController.value.text,
                              color: colorPick.value,
                            ));
                  },
            child: const Text('Add')),
      ],
    );
  }
}

class AddCategoryConfirmationDialog extends ConsumerWidget {
  final String name;
  final int color;
  const AddCategoryConfirmationDialog({required this.name, required this.color, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Add `$name` category ?', style: const TextStyle(fontSize: 20)),
      contentPadding: const EdgeInsets.all(24),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'WARNING! Category that have been added cannot be deleted further. Do you want to proceed?')
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
              ref
                  .read(transactionCategoryProvider.notifier)
                  .addTransactionCategory(name: name, color: color);
              pushGlobalSnackbar(message: 'Category added');
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Proceed')),
      ],
    );
  }
}
