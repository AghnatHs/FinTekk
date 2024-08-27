import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// |title                data|
// |title                data|
// |title                data|
// |title                data|

class ReportRow extends ConsumerWidget {
  final String title;
  final String data;
  final TextStyle? dataStyle;
  const ReportRow({super.key, required this.title, required this.data, this.dataStyle });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(data, style: dataStyle,),
      ],
    );
  }
}
