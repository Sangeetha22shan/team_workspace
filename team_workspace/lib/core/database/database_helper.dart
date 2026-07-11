import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = 'team_workspace.db';
  static const int dbVersion = 1;
  static const String tasksTable = 'tasks';

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tasksTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT,
        status TEXT,
        dueDate TEXT,
        assignedTo TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    if (oldVersion < newVersion) {
      // Drop the old table and create a new one (for development)
      // In production, you'd want proper migrations
      await db.execute('DROP TABLE IF EXISTS $tasksTable');
      await _onCreate(db, newVersion);
    }
  }

  // Task operations
  Future<int> insertTask(Map<String, dynamic> taskMap) async {
    final db = await database;
    return await db.insert(
      tasksTable,
      taskMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertAllTasks(List<Map<String, dynamic>> tasks) async {
    final db = await database;
    int count = 0;
    await db.transaction((txn) async {
      for (var task in tasks) {
        await txn.insert(
          tasksTable,
          task,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    });
    return count;
  }

   Future<List<Map<String, dynamic>>> getAllTasks() async {
     final db = await database;
     return await db.query(tasksTable);
   }

    Future<List<Map<String, dynamic>>> getTasks({int? limit, int? offset}) async {
      final db = await database;
      // If no pagination requested, return all tasks
      if (limit == null) {
        return await db.query(tasksTable);
      }

      return await db.query(
        tasksTable,
        limit: limit,
        offset: offset,
      );
    }

     /// Get tasks where numeric(id) < [lastId], ordered by numeric(id) descending.
     /// Useful for id-based pagination when id is stored as TEXT in the DB.
     /// For lastId = 0 (initial load), returns the most recent tasks.
     Future<List<Map<String, dynamic>>> getTasksAfterId({
       required int lastId,
       required int limit,
     }) async {
       final db = await database;
       // Use CAST to ensure numeric comparison when id is TEXT
       if (lastId == 0) {
         // Initial load: get the most recent tasks (ordered by id DESC)
         final results = await db.rawQuery(
           'SELECT * FROM $tasksTable ORDER BY CAST(id AS INTEGER) DESC LIMIT ?;',
           [limit],
         );
         return results;
       } else {
         // Load older tasks: get tasks with id < lastId
         final results = await db.rawQuery(
           'SELECT * FROM $tasksTable WHERE CAST(id AS INTEGER) < ? ORDER BY CAST(id AS INTEGER) DESC LIMIT ?;',
           [lastId, limit],
         );
         return results;
       }
     }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateTask(Map<String, dynamic> taskMap) async {
    final db = await database;
    return await db.update(
      tasksTable,
      taskMap,
      where: 'id = ?',
      whereArgs: [taskMap['id']],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await database;
    return await db.delete(tasksTable);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}

