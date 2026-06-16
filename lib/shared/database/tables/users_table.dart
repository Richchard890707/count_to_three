import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().withLength(max: 255)();
  TextColumn get displayName => text().withLength(max: 100)();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
