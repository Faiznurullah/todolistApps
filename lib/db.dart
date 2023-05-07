import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static sql.Database? _database;

  static Future<sql.Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    // Initialize database if it doesn't exist
    _database = await initDatabase();

    return _database!;
  }

  static Future<sql.Database> initDatabase() async {
    final databasePath = await sql.getDatabasesPath();
    final path = join(databasePath, 'database.db');

    // Open the database and create it if it doesn't exist
    return sql.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE data(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            desc TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  static Future<int> createData(String title, String? desc) async {
    final db = await getDatabase();

    final data = {
      'title': title,
      'desc': desc,
    };
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await getDatabase();

    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await getDatabase();
    return db.query('data', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await getDatabase();
    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('data', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await getDatabase();
    try {
      await db.delete('data', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}
