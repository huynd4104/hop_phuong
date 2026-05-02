import 'package:isar/isar.dart';

part 'user_entity.g.dart';

@Name('UserModel')
@collection
class User {
  User({this.id = Isar.autoIncrement, required this.name, required this.phone, this.isOwner = false});

  Id id = Isar.autoIncrement;

  late String name;

  late String phone;

  @Index()
  bool isOwner = false;
}
