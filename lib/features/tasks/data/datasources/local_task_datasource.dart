import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'task_content_data.dart';
import '../../domain/entities/task_category.dart';

/// Local Data Source for managing Tasks in SQLite
class LocalTaskDataSource {
  static Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vicdan_tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Bumped to 3 for startHour
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category INTEGER NOT NULL,
        xpValue INTEGER NOT NULL,
        startHour INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL,
        completedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE task_history (
        date TEXT PRIMARY KEY,
        totalScore INTEGER NOT NULL,
        completedCount INTEGER NOT NULL,
        totalCount INTEGER NOT NULL
      )
    ''');

    // Seed initial data
    await _seedInitialTasks(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE task_history (
          date TEXT PRIMARY KEY,
          totalScore INTEGER NOT NULL,
          completedCount INTEGER NOT NULL,
          totalCount INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add startHour column
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN startHour INTEGER NOT NULL DEFAULT 0');
    }
  }

  /// Initial Seed Data (Hardcoded for MVP)
  Future<void> _seedInitialTasks(Database db) async {
    final initialTasks = [
      // IBADET
      TaskModel.create(
        id: _uuid.v4(),
        title: 'Sabah Namazı',
        description: 'Günün ilk nuru. Vaktinde kıl.',
        category: TaskCategory.ibadet,
        xpValue: 30, // High XP
      ),
      TaskModel.create(
        id: _uuid.v4(),
        title: '5 Ayet Oku',
        description: 'Ruhunu Kuran ile besle.',
        category: TaskCategory.ibadet,
        xpValue: 15,
      ),

      // IYILIK
      TaskModel.create(
        id: _uuid.v4(),
        title: 'Birine Gülümse',
        description: 'Sadaka niyetine bir tebessüm.',
        category: TaskCategory.iyilik,
        xpValue: 10,
      ),
      TaskModel.create(
        id: _uuid.v4(),
        title: 'Sadaka Ver',
        description: 'Az da olsa paylaş.',
        category: TaskCategory.iyilik,
        xpValue: 25,
      ),

      // ZIHIN
      TaskModel.create(
        id: _uuid.v4(),
        title: '3 Kez Şükret',
        description: 'Sahip olduklarını hatırla.',
        category: TaskCategory.zihin,
        xpValue: 10,
      ),
      TaskModel.create(
        id: _uuid.v4(),
        title: 'Günü Tefekkür Et',
        description: 'Bugün Allah için ne yaptın?',
        category: TaskCategory.zihin,
        xpValue: 20,
      ),
    ];

    for (var task in initialTasks) {
      await db.insert('tasks', task.toMap());
    }
  }

  /// Get all tasks
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');

    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  /// Mark task as complete/incomplete
  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    final db = await database;

    await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reset all tasks (Daily Reset)
  // Modified to re-seed tasks for the new day
  Future<void> resetDailyTasks(int dayIndex) async {
    final db = await database;

    // Clear current tasks
    await db.delete('tasks');

    // Get blueprint for the specific day
    final blueprints = TaskContentData.getTasksForDay(dayIndex);

    // Convert Blueprint to Model (generate IDs)
    final batch = db.batch();
    for (var i = 0; i < blueprints.length; i++) {
      final bp = blueprints[i];
      final task = TaskModel.create(
        id: 'day_${dayIndex}_task_$i',
        title: bp.title,
        description: bp.description,
        category: bp.category,
        xpValue: bp.xpValue,
        startHour: bp.startHour,
      );
      batch.insert('tasks', task.toMap());
    }

    await batch.commit();
  }

  /// Archive daily progress
  Future<void> archiveDailyProgress(String dateStr) async {
    final db = await database;
    final tasks = await getTasks();

    int totalScore = 0;
    int completedCount = 0;
    int totalCount = tasks.length;

    int totalPossibleXp = 0;

    for (var task in tasks) {
      totalPossibleXp += task.xpValue;
      if (task.isCompleted) {
        completedCount++;
        // Calculate score percentage logic locally to match
        // Or just store raw XP.
        // Storing percentage (0-100) is easier for UI.
      }
    }

    // Calculate percentage score based on XP
    for (var task in tasks) {
      if (task.isCompleted) {
        totalScore += task.xpValue;
      }
    }

    // Normalize to 0-100
    int normalizedScore = 0;
    if (totalPossibleXp > 0) {
      normalizedScore = ((totalScore / totalPossibleXp) * 100).round();
    }

    await db.insert(
      'task_history',
      {
        'date': dateStr,
        'totalScore': normalizedScore, // 0-100
        'completedCount': completedCount,
        'totalCount': totalCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory(int days) async {
    final db = await database;
    // Get last X days
    return await db.query(
      'task_history',
      orderBy: 'date DESC',
      limit: days,
    );
  }

  /// Add a new task
  Future<void> addTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Restore default tasks (Clears current tasks and reseeds)
  Future<void> restoreDefaults() async {
    final db = await database;
    await db.delete('tasks');
    await _seedInitialTasks(db);
  }

  /// Get total completed tasks across all time (history + current)
  Future<int> getTotalCompletedTasksCount() async {
    final db = await database;

    // 1. Sum completedCount from history
    final historyResult = await db
        .rawQuery('SELECT SUM(completedCount) as total FROM task_history');
    int historyCount = (historyResult.first['total'] as num?)?.toInt() ?? 0;

    // 2. Count completed tasks from current active tasks
    final currentResult = await db
        .rawQuery('SELECT COUNT(*) as total FROM tasks WHERE isCompleted = 1');
    int currentCount = (currentResult.first['total'] as num?)?.toInt() ?? 0;

    return historyCount + currentCount;
  }
}
