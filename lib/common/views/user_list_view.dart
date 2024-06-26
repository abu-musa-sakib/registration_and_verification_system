import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
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

    // Open the database file. If it doesn't exist, it will be created.
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';

    await db.execute('''
    CREATE TABLE users ( 
      id $idType, 
      name $textType
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

    return result
        .map(
            (json) => User(id: json['id'] as String, name: json['name'] as String))
        .toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = UserDatabase.instance.readAllUsers();
  }

  @override
  void dispose() {
    UserDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users found'));
            } else {
              final users = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                  ],
                  rows: users
                      .map(
                        (user) => DataRow(cells: [
                          DataCell(Text(user.id.toString())),
                          DataCell(Text(user.name)),
                        ]),
                      )
                      .toList(),
                  headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey),
                  dataRowColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade200),
                  dataRowMaxHeight: 60,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  columnSpacing: 30,
                  dividerThickness: 2,
                  border: TableBorder.all(width: 1.5, color: Colors.grey),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: UserListView(),
  ));
}
