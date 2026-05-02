import 'package:isar/isar.dart';

part 'payment_status_entity.g.dart';

@collection
class PaymentStatus {
  PaymentStatus({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.roundId,
    this.isPaid = false,
  });

  Id id = Isar.autoIncrement;

  late int userId;

  late int roundId;

  late bool isPaid;
}
