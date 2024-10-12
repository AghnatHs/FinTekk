import 'dart:async';
import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final internalTransferProvider =
    AsyncNotifierProvider<InternalTransferNotifer, List<InternalTransfer>>(
        InternalTransferNotifer.new);

class InternalTransferNotifer extends AsyncNotifier<List<InternalTransfer>> {
  DatabaseHelper? db;

  @override
  FutureOr<List<InternalTransfer>> build() async {
    db = ref.watch(databaseProvider);

    List<Map<dynamic, dynamic>> query = await db!.getAllInternalTransfer();
    List<InternalTransfer> internalTransfers = query
        .map((data) => InternalTransfer.fromMap(data))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return internalTransfers.reversed.toList();
  }

  void addInternalTransfer(
      {required String linkedTransferId,
      required String accountId,
      required int amount,
      required String type,
      required String date}) async {
    String id = 'internaltransfer-${const Uuid().v7()}';
    await db!.addInternalTransfer(InternalTransfer(
      id: id,
      linkedTransferId: linkedTransferId,
      accountId: accountId,
      amount: amount,
      type: type,
      date: date,
      accountName: ''
    ));
    ref.invalidateSelf();
  }

  void deleteInternalTransferLinked({required String linkedTransferId}) async {
    await db!.deleteInternalTransfer(linkedTransferId);
    ref.invalidateSelf();
  }
}
