import 'dart:async';
import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EnterDetailsView extends StatefulWidget {
  final String image;
  final FaceFeatures faceFeatures;
  const EnterDetailsView({
    super.key,
    required this.image,
    required this.faceFeatures,
  });

  @override
  State<EnterDetailsView> createState() => _EnterDetailsViewState();
}

class _EnterDetailsViewState extends State<EnterDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

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

  Future<void> _insertUser(UserModel user) async {
    try {
      await _database.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Log the inserted user
      List<Map<String, dynamic>> users =
          await _database.rawQuery('SELECT * FROM users');
      debugPrint('Inserted user: $user');
      debugPrint('All users: $users');
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop four times to go back three steps
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Details"),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String userId = UniqueKey().toString();
                      UserModel user = UserModel(
                        id: userId,
                        name: _nameController.text.trim().toUpperCase(),
                        image: widget.image,
                        faceFeatures: widget.faceFeatures,
                        registeredOn: DateTime.now().millisecondsSinceEpoch,
                      );

                      try {
                        await _insertUser(user);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration Success!'),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration Failed! Try Again.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Register Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
