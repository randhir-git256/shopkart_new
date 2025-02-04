import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'dart:io';

part 'local_database.g.dart';

class LocalUsers extends Table {
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();

  @override
  Set<Column> get primaryKey => {userId};
}

class LocalProducts extends Table {
  TextColumn get productId => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [LocalUsers, LocalProducts])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._(QueryExecutor e) : super(e);

  static LocalDatabase? _instance;

  static Future<LocalDatabase> getInstance() async {
    if (_instance == null) {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      _instance = LocalDatabase._(NativeDatabase(file));
    }
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  // Debug method to get all users
  Future<List<LocalUser>> getAllUsers() => select(localUsers).get();

  // Debug method to get all products
  Future<List<LocalProduct>> getAllProducts() => select(localProducts).get();

  // Debug method to print database contents
  Future<void> printDatabaseContents() async {
    print('\n=== LOCAL DATABASE CONTENTS ===');

    print('\nUSERS:');
    final users = await getAllUsers();
    for (var user in users) {
      print('${user.name} (${user.email}) - ${user.role}');
    }

    print('\nPRODUCTS:');
    final products = await getAllProducts();
    for (var product in products) {
      print(
          '${product.name} - \$${product.price} (Qty: ${product.quantity}) - ${product.imageUrl} - ${product.description}');
    }

    print('\n============================\n');
  }
}
