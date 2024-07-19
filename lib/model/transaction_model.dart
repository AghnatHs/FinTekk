class Transactionn {
  String? id;
  String? transactionCategoryId;
  String? accountId;
  String? date;
  int? amount;
  String? description;
  String? type;
  String? category;
  String? account;
  Transactionn({
    required this.id,
    required this.transactionCategoryId,
    required this.accountId,
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
    required this.category,
    required this.account,
  });

  factory Transactionn.fromMap(Map<dynamic, dynamic> map) {
    return Transactionn(
      id: map['transaction_id'] as String,
      transactionCategoryId: map['transaction_category_id'] as String,
      accountId: map['account_id'] as String,
      date: map['date'] as String,
      amount:  map['amount'] as int,
      description: map['description'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      account: map['account'] as String
    );
  }

  Transactionn copyWith(
    String? id,
    String? transactionCategoryId,
    String? accountId,
    String? date,
    int? amount,
    String? description,
    String? type,
    String? category,
    String? account,
  ) {
    return Transactionn(
      id: id ?? this.id,
      transactionCategoryId: transactionCategoryId ?? this.transactionCategoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      account: account ?? this.account,
    );
  }

  @override
  bool operator ==(covariant Transactionn other) {
    if (identical(this, other)) return true;

    return other.id == id && other.transactionCategoryId == transactionCategoryId;
  }

  @override
  int get hashCode => id.hashCode ^ transactionCategoryId.hashCode;

  @override
  String toString() {
    return 'Transaction [$id] $date $amount $description $type $category $account ';
  }
}
