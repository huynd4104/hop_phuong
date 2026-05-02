import 'package:isar/isar.dart';

part 'payment_status_entity.g.dart';

@embedded
class PaymentEntry {
  PaymentEntry({this.amount, this.date, this.note});
  int? amount;
  DateTime? date;
  String? note;
}

@Name('StatusCol')
@collection
class PaymentStatus {
  PaymentStatus({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.roundId,
    this.isPaid = false,
    this.history,
  });

  Id id = Isar.autoIncrement;

  late int userId;

  late int roundId;

  late bool isPaid;

  List<PaymentEntry>? history;

  // Helper to get total actual amount
  int get totalActualAmount => history?.fold(0, (sum, e) => (sum ?? 0) + (e.amount ?? 0)) ?? 0;
}
