import 'package:flutter/material.dart';

class GeneralConfimationDialog extends StatelessWidget {
  final String title;
  final String content;
  const GeneralConfimationDialog({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('NO')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('YES')),
      ],
    );
  }
}
