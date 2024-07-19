String currencyFormat(
  String src, [
  String? prefix,
  String? currency,
]) {
  prefix ??= int.tryParse(src)!.sign == -1 ? 'Expense' : 'Income';
  currency = currency ?? 'Rp';
  List srcSplit = src.split('.');
  String afterComma = '';

  try {
    //check if it has decimal value
    if (srcSplit.length == 2) {
      afterComma = ',${srcSplit[1]}';
    } else {
      afterComma = '';
    }

    //add . to left (before decimal)
    List left = List.from(srcSplit[0].split('').reversed);
    List results = [];

    for (int i = 0; i < left.length; i++) {
      if ((i + 1) % 3 == 0) {
        results.add(left[i]);
        results.add('.');
      } else {
        results.add(left[i]);
      }
    }

    //remove . if it is in last
    if (results[results.length - 1] == '.') {
      results.removeLast();
    } else if (results[results.length - 1] == '-') {
      if (results[results.length - 2] == '.') {
        results.removeAt(results.length - 2);
      }
    }

    prefix == 'Expense' ? prefix = '-$currency' : prefix = '+$currency';

    //result
    results = List.from(results.reversed);
    results.remove('-');

    return prefix + results.join() + afterComma;
  } catch (e) {
    // Error
  }

  prefix == 'Expense' ? prefix = '-$currency' : prefix = '+$currency';
  return '${prefix}0';
}

String rawCurrencyFormat(String src, [String? currency]) {
  currency = currency ?? 'Rp';
  List srcSplit = src.split('.');
  String afterComma = '';

  //check if it has decimal value
  if (srcSplit.length == 2) {
    afterComma = ',${srcSplit[1]}';
  } else {
    afterComma = '';
  }

  //add . to left (before decimal)
  List left = List.from(srcSplit[0].split('').reversed);
  List results = [];

  for (int i = 0; i < left.length; i++) {
    if ((i + 1) % 3 == 0) {
      results.add(left[i]);
      results.add('.');
    } else {
      results.add(left[i]);
    }
  }

  //remove . if it is in last
  if (results[results.length - 1] == '.') {
    results.removeLast();
  } else if (results[results.length - 1] == '-') {
    if (results[results.length - 2] == '.') {
      results.removeAt(results.length - 2);
    }
  }

  //result
  results = List.from(results.reversed);
  results.remove('-');

  return currency + results.join() + afterComma;
}
