import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// This class manages all SQLite operations
// Think of it as the middleman between your app and the database
class DatabaseHelper {

  // Singleton pattern — only one instance of database exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // This getter opens the database if not already open
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kidlearn.db');
    return _database!;
  }

  // Creates the database file on the phone
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Creates the offline_videos table
  // This runs only once when the app is installed
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // INSERT — save a new video to database
  Future<int> insertVideo(Map<String, dynamic> video) async {
    final db = await database;
    return await db.insert('offline_videos', video);
  }

  // SELECT — get all videos from database
  Future<List<Map<String, dynamic>>> getAllVideos() async {
    final db = await database;
    return await db.query('offline_videos', orderBy: 'created_at DESC');
  }

  // DELETE — remove a video from database
  Future<int> deleteVideo(int id) async {
    final db = await database;
    return await db.delete(
      'offline_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}