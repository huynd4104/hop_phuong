import 'package:isar/isar.dart';

part 'pool_member_entity.g.dart';

@Name('PoolMemberModel')
@collection
class PoolMember {
  PoolMember({this.id = Isar.autoIncrement, required this.poolId, required this.userId});

  Id id = Isar.autoIncrement;

  @Index()
  late int poolId;

  @Index(name: 'user_index')
  late int userId;
}
