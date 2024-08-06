class TranscactionCategory {
  String? id;
  String? name;
  int? color;
  TranscactionCategory({required this.id, required this.name, required this.color});

  factory TranscactionCategory.fromMap(Map<dynamic, dynamic> map) {
    return TranscactionCategory(
      id: map['transaction_category_id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
    );
  }

  TranscactionCategory copyWith({String? id, String? name, int? color}) {
    return TranscactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
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
    return 'Category [$name] [$id] [$color]';
  }
}
