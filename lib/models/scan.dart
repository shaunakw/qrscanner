import 'package:hive/hive.dart';

part 'scan.g.dart';

@HiveType(typeId: 0)
class Scan extends HiveObject {
  @HiveField(0)
  String data;

  @HiveField(1)
  DateTime date;

  Scan(this.data, {DateTime? date}) : date = date ?? DateTime.now();
}
