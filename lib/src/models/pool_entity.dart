import 'package:isar/isar.dart';

part 'pool_entity.g.dart';

@Name('PoolModel')
@collection
class Pool {
  Pool({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.baseAmount,
    required this.totalRounds,
    required this.meetingDay,
    required this.startDate,
  });

  Id id = Isar.autoIncrement;

  late String name;

  late int baseAmount;

  late int totalRounds;

  late int meetingDay;

  late DateTime startDate;
}
