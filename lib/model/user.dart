import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final String id;
  final String name;
  final String image;
  final int registeredOn;

  User({required this.id, required this.name, required this.image, required this.registeredOn});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'registeredOn': registeredOn,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      registeredOn: map['registeredOn'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, registeredOn: $registeredOn}';
  }
}

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const integerType = 'INTEGER';

    await db.execute('''
    CREATE TABLE users ( 
      id $idType, 
      name $textType,
      image $textType,
      registeredOn $integerType
      )
    ''');
  }

  Future<void> createUser(User user) async {
    final db = await instance.database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> readAllUsers() async {
    final db = await instance.database;

    final result = await db.query('users');

    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<User?> readUser(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'image', 'registeredOn'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteUser(String id) async {
    final db = await instance.database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
