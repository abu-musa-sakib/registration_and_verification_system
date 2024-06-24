import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/common/utils/custom_button.dart';
import 'package:registration_and_verification_system/common/utils/custom_text_field.dart';
import 'package:registration_and_verification_system/common/views/user_list_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:registration_and_verification_system/common/utils/custom_snackbar.dart';
import 'package:registration_and_verification_system/constants/theme.dart';

class EnterPasswordView extends StatefulWidget {
  const EnterPasswordView({super.key, Key? K});

  @override
  State<EnterPasswordView> createState() => _EnterPasswordViewState();
}

class _EnterPasswordViewState extends State<EnterPasswordView> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Database _database;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'password_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE IF NOT EXISTS passwords(id INTEGER PRIMARY KEY, password TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<bool> _isPasswordCorrect(String password) async {
    try {
      final List<Map<String, dynamic>> passwords = await _database.query(
        'passwords',
        where: 'password = ?',
        whereArgs: [password],
      );
      return passwords.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check password: $e');
    }
  }

  Future<void> _insertPassword(String password) async {
    try {
      final List<Map<String, dynamic>> passwords = await _database.query(
        'passwords',
        limit: 1,
      );

      if (passwords.isNotEmpty) {
        // CustomSnackBar.errorSnackBar("Password already set");
        return;
      }

      await _database.insert(
        'passwords',
        {'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      CustomSnackBar.successSnackBar("Password set successfully");
    } catch (e) {
      throw Exception('Failed to insert password: $e');
    }
  }

  void _authenticatePassword(
      String enteredPassword, BuildContext context) async {
    try {
      final List<Map<String, dynamic>> passwords = await _database.query(
        'passwords',
        limit: 1,
      );

      if (passwords.isEmpty) {
        CustomSnackBar.errorSnackBar("No password set");
        return;
      }

      final String storedPassword = passwords.first['password'];
      if (enteredPassword == storedPassword) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserListView(),
          ),
        );
      } else {
        CustomSnackBar.errorSnackBar("Incorrect password. Please try again.");
        Navigator.of(context).pop();
      }
    } catch (e) {
      CustomSnackBar.errorSnackBar("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Enter Password"),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldTopGradientClr,
              scaffoldBottomGradientClr,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    formFieldKey: GlobalKey(),
                    controller: _controller,
                    hintText: "Password",
                    validatorText: "Enter password to proceed",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Continue",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        try {
                          await _insertPassword(_controller.text.trim());
                          _authenticatePassword(
                              _controller.text.trim(), context);
                        } catch (e) {
                          CustomSnackBar.errorSnackBar("Error: $e");
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
