class TranscactionCategory {
  String? id;
  String? name;
  TranscactionCategory({required this.id, required this.name});

  factory TranscactionCategory.fromMap(Map<dynamic, dynamic> map) {
    return TranscactionCategory(
      id: map['transaction_category_id'] as String,
      name: map['name'] as String,
    );
  }

  TranscactionCategory copyWith({String? id, String? name}) {
    return TranscactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(covariant TranscactionCategory other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Category [$name] [$id]';
  }
}
