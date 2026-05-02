import 'package:isar/isar.dart';

part 'round_entity.g.dart';

@collection
class Round {
  Round({
    this.id = Isar.autoIncrement,
    required this.poolId,
    required this.roundNumber,
    required this.date,
    this.winnerId,
    this.bidAmount = 0,
    this.contributionAmount = 0,
    this.payoutAmount = 0,
    this.netReceiveAmount = 0,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late int poolId;

  late int roundNumber;

  late DateTime date;

  int? winnerId;

  late int bidAmount;

  late int contributionAmount;

  late int payoutAmount;

  late int netReceiveAmount;
}
