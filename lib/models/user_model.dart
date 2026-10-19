import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  // سيبنا HiveField(1) بدون استخدام عشان بيانات Hive القديمة
  @HiveField(2)
  String goal;

  UserModel({
    required this.name,
    required this.goal,
  });
}