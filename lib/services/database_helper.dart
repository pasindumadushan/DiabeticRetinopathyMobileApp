import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'retina_insight.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE patient_records ADD COLUMN image_paths TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE patient_records ADD COLUMN severity TEXT');
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patient_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        diabetic TEXT,
        diabetes_duration REAL,
        email TEXT,
        image_paths TEXT,
        severity TEXT,
        created_at TEXT NOT NULL
      )
    ''' );
  }

  Future<int> insertPatientRecord(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(
      'patient_records',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updatePatientRecordImagePaths(int patientId, String? imagePaths) async {
    final db = await database;
    return db.update(
      'patient_records',
      {'image_paths': imagePaths},
      where: 'id = ?',
      whereArgs: [patientId],
    );
  }

  Future<int> updatePatientRecordSeverity(int patientId, String severity) async {
    final db = await database;
    return db.update(
      'patient_records',
      {'severity': severity},
      where: 'id = ?',
      whereArgs: [patientId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchPatientRecords() async {
    final db = await database;
    return db.query('patient_records', orderBy: 'created_at DESC');
  }
}
