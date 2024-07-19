import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:fl_finance_mngt/notifier/transaction/transaction_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: FOR LATER USE

final transactionCategoryQueryProvider =
    StateNotifierProvider<CategoryQueryNotifier, String>((ref) => CategoryQueryNotifier(''));
final transactionAccountQueryProvider =
    StateNotifierProvider<AccountQueryNotifier, String>((ref) => AccountQueryNotifier(''));
final transactionTypeQueryProvider =
    StateNotifierProvider<TypeQueryNotifier, String>((ref) => TypeQueryNotifier(''));

final filteredTransactionsByCategoryProvider = FutureProvider<List<Transactionn>>((ref) async {
  final query = ref.watch(transactionCategoryQueryProvider);
  final transactions = await ref.watch(transactionProvider.future);
  return transactions.where((transaction) => transaction.category == query).toList();
});
final filteredTransactionsByAccountProvider = FutureProvider<List<Transactionn>>((ref) async {
  final query = ref.watch(transactionAccountQueryProvider);
  final transactions = await ref.watch(transactionProvider.future);
  return transactions.where((transaction) => transaction.account == query).toList();
});
final filteredTransactionsByTypeProvider = FutureProvider<List<Transactionn>>((ref) async {
  final query = ref.watch(transactionTypeQueryProvider);
  final transactions = await ref.watch(transactionProvider.future);
  return transactions.where((transaction) => transaction.type == query).toList();
});

class CategoryQueryNotifier extends StateNotifier<String> {
  CategoryQueryNotifier(super.state);

  void setQuery({required String query}) {
    state = query;
  }
}
class AccountQueryNotifier extends StateNotifier<String> {
  AccountQueryNotifier(super.state);

  void setQuery({required String query}) {
    state = query;
  }
}
class TypeQueryNotifier extends StateNotifier<String> {
  TypeQueryNotifier(super.state);

  void setQuery({required String query}) {
    state = query;
  }
}
