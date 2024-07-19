class Account {
  String? id;
  String? name;
  Account({required this.id, required this.name});

  factory Account.fromMap(Map<dynamic, dynamic> map) {
    return Account(
      id: map['account_id'] as String,
      name: map['name'] as String,
    );
  }

  Account copyWith(String? id, String? name) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(covariant Account other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'A [$name] [$id]';
  }
}
