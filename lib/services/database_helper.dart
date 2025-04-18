import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'app_data.db'),
      version: 3,
      onCreate: (db, version) async {
        // Users table
        await db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)'
        );
        // Comments table
        await db.execute(
            '''
          CREATE TABLE comments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            videoIndex INTEGER,
            text TEXT,
            timestamp TEXT
          )
          '''
        );
        // Flowchart table
        await db.execute(
            '''
          CREATE TABLE flowcharts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            videoIndex INTEGER,
            flowchartData TEXT
          )
          '''
        );
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute(
              '''
            CREATE TABLE comments(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              videoIndex INTEGER,
              text TEXT,
              timestamp TEXT
            )
            '''
          );
        }
        if (oldV < 3) {
          await db.execute(
              '''
            CREATE TABLE flowcharts(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              videoIndex INTEGER,
              flowchartData TEXT
            )
            '''
          );
        }
      },
    );
  }

  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return db.insert('users', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return res.isNotEmpty ? res.first : null;
  }

  /// Insert a new comment
  Future<int> insertComment(int videoIndex, String text) async {
    final db = await database;
    return db.insert('comments', {
      'videoIndex': videoIndex,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch all comments for a given video (newest first)
  Future<List<Map<String, dynamic>>> getComments(int videoIndex) async {
    final db = await database;
    return db.query(
      'comments',
      where: 'videoIndex = ?',
      whereArgs: [videoIndex],
      orderBy: 'id DESC',
    );
  }

  /// Insert  flowchart as a JSON string for a given video
  Future<int> insertFlowchart(int videoIndex, String flowchartData) async {
    final db = await database;
    return db.insert('flowcharts', {
      'videoIndex': videoIndex,
      'flowchartData': flowchartData,
    });
  }

  /// Fetch the flowchart for a given video
  Future<String?> getFlowchart(int videoIndex) async {
    final db = await database;
    final result = await db.query(
      'flowcharts',
      where: 'videoIndex = ?',
      whereArgs: [videoIndex],
    );
    if (result.isNotEmpty) {
      return result.first['flowchartData'] as String;
    }
    return null;
  }
}
