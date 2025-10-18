import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_nexus/models/product.dart';
import 'package:firebase_nexus/models/supabaseProduct.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLFliteDatabaseHelper {
  static final SQLFliteDatabaseHelper _instance =
      SQLFliteDatabaseHelper._internal();
  factory SQLFliteDatabaseHelper() => _instance;
  SQLFliteDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    copyDatabaseForDebug();

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
    print('🧨 Database deleted — will be recreated on next launch');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL, 
      price REAL NOT NULL,
      tags TEXT
      )
    ''');

    // await db.execute('''DROP TABLE IF EXISTS cart ''');
    // Cart table — matches SupabaseProduct model
    await db.execute('''
    CREATE TABLE cart (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      prodId INTEGER ,
      included INTEGER NOT NULL CHECK (included IN (0, 1)),
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      img_path TEXT,                          -- store image URL or path
      variation TEXT,                    
      price REAL,                    
      quantity INTEGER NOT NULL
    )
  ''');
  }

  Future<void> copyDatabaseForDebug() async {
    // Get the path to the real database file
    final dbDir = await getDatabasesPath();
    final dbPath =
        join(dbDir, 'app_database.db'); // 👈 must be a file, not directory!

    // Check if the file exists
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      print('❌ Database file not found at $dbPath');
      return;
    }

    // Copy it to a more accessible temp directory
    final tempDir = await getTemporaryDirectory();
    final newPath = join(tempDir.path, 'debug_copy.db');
    await dbFile.copy(newPath);

    print('✅ Debug copy created at: $newPath');
  }

  Future<Map<String, dynamic>> insertCart(
    String table,
    SupabaseProduct product,
  ) async {
    final db = await database;

    try {
      // Step 1: Check if a row with same prodID and variation already exists
      final existing = await db.query(
        table,
        where: 'prodId = ? AND variation = ?',
        whereArgs: [product.prodId, product.variation],
      );

      print('existing');
      print(existing);

      if (existing.isNotEmpty) {
        // Step 2: Merge quantity with the existing one
        final existingRow = existing.first;
        final newQuantity =
            (existingRow['quantity'] as int) + (product.quantity ?? 1);

        // Step 3: Update the row
        await db.update(
          table,
          {
            'quantity': newQuantity,
          },
          where: 'prodId = ? AND variation = ?',
          whereArgs: [product.prodId, product.variation],
        );

        return {
          'success': true,
          'id': existingRow['id'],
          'message':
              'Quantity updated for existing product in $table successfully.',
          'data': {...product.toJson(), 'quantity': newQuantity},
        };
      } else {
        print('no existing');

        // Step 4: Insert new row if no match found
        final id = await db.insert(
          table,
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return {
          'success': true,
          'id': id,
          'message': 'Product added to $table successfully.',
          'data': product.toJson(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'id': null,
        'message': 'Error inserting product: $e',
        'data': null,
      };
    }
  }

  Future<void> updateCartQuantity(String table, int id, bool increment) async {
    final db = await database;

    // Fetch the row
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return; // No such item

    final currentQuantity = result.first['quantity'] as int;
    final newQuantity = increment ? currentQuantity + 1 : currentQuantity - 1;

    if (newQuantity <= 0) {
      // Delete the row if quantity would reach 0
      await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      // Otherwise, just update the quantity
      await db.update(
        table,
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> includeCheckout(int id, bool include) async {
    final db = await database;

    // Fetch the row
    final result = await db.query(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return; // No such item

    await db.update(
      'cart',
      {'included': include ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //Insert Product
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', {...product.toMap()},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SupabaseProduct>> getCart() async {
    final db = await database;
    final result = await db.query('Cart');

    print(
        'result ---------------------------------------------------------------------------------------------------');
    print(result);

    return result.map((map) {
      final data = {...map};
      return SupabaseProduct.fromMap(data);
    }).toList();
  }

  //update cart
  Future<int> updateCart(SupabaseProduct product) async {
    final db = await database;
    return await db.update('products', {...product.toMap()},
        where: 'id=?', whereArgs: [product.id]);
  }

  //update product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', {...product.toMap()},
        where: 'id=?', whereArgs: [product.id]);
  }

  //delete product
  Future<int> deleteRow(String table, int? id) async {
    final db = await database;
    return await db.delete(table, where: 'id=?', whereArgs: [id]);
  }
}

Map<String, Color> getStatColor(String status) {
  switch (status) {
    case 'Available':
      return {'labelColor': Color(0xFFB6EAC7), 'textColor': Color(0xFF2E7D32)};

    case 'Inactive':
      return {
        'labelColor': Color.fromARGB(255, 239, 175, 0),
        'textColor': Color.fromARGB(255, 255, 255, 255)
      };

    case 'Out of Stock':
      return {
        'labelColor': Color(0xFFE0E0E0),
        'textColor': Color.fromARGB(255, 193, 13, 13)
      };

    default:
      return {'labelColor': Color(0xFFE0E0E0), 'textColor': Color(0xFF757575)};
  }
}
