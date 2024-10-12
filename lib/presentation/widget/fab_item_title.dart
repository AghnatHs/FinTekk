import 'package:flutter/material.dart';

class FabItemTitle extends StatelessWidget {
  final String title;
  const FabItemTitle({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(5),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
