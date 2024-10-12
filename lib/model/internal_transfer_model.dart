import 'package:fl_finance_mngt/model/abstracts/abstract_transaction_model.dart';

class InternalTransfer implements TransactionObject {
  String id;
  String linkedTransferId;
  String accountId;
  int amount;
  String type;
  @override
  String date;
  String accountName;
  InternalTransfer(
      {required this.id,
      required this.linkedTransferId,
      required this.accountId,
      required this.amount,
      required this.type,
      required this.date,
      required this.accountName});

  factory InternalTransfer.fromMap(Map<dynamic, dynamic> map) {
    return InternalTransfer(
        id: map['internal_transfer_id'] as String,
        linkedTransferId: map['linked_transfer_id'] as String,
        accountId: map['account_id'] as String,
        amount: map['amount'] as int,
        type: map['type'] as String,
        date: map['date'] as String,
        accountName: map['account_name'] as String);
  }

  InternalTransfer copyWith(String? id, String? accountId, int? amount, String? type,
      String? date, String? accountName) {
    return InternalTransfer(
        id: id ?? this.id,
        linkedTransferId: linkedTransferId,
        accountId: accountId ?? this.accountId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        date: date ?? this.date,
        accountName: accountName ?? this.accountName);
  }

  @override
  bool operator ==(covariant InternalTransfer other) {
    if (identical(this, other)) return true;

    return other.id == id && other.accountId == accountId;
  }

  @override
  int get hashCode => id.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'InternalTransfer $id $accountId $amount $type $date';
  }
}
