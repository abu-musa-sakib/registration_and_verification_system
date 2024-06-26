import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:registration_and_verification_system/authenticate_face/user_details_view.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class CheckUserView extends StatefulWidget {
  const CheckUserView({super.key});

  @override
  _CheckUserViewState createState() => _CheckUserViewState();
}

class _CheckUserViewState extends State<CheckUserView> {
  final TextEditingController _idController = TextEditingController();
  late Database _database;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, image TEXT, faceFeatures TEXT, registeredOn INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<UserModel?> _getUserById(String id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                hintText: "User ID",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'User ID cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_idController.text.isNotEmpty) {
                  UserModel? user = await _getUserById(_idController.text);
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User found: ${user.name}')),
                    );
                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserDetailsView(user: user),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User not found.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Check User'),
            ),
          ],
        ),
      ),
    );
  }
}
