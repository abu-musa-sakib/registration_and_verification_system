import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/authenticate_face/user_details_view.dart';
import 'package:registration_and_verification_system/model/user.dart';

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
    _refreshUsers();
  }

  @override
  void dispose() {
    UserDatabase.instance.close();
    super.dispose();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = UserDatabase.instance.readAllUsers();
    });
  }

  Future<void> _deleteUser(String id) async {
    await UserDatabase.instance.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User deleted successfully!'),
      ),
    );
    _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'List of Users',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
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
                          DataColumn(label: Text('Delete')),
                        ],
                        rows: users
                            .map(
                              (user) => DataRow(
                                cells: [
                                  DataCell(Text(user.id), onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDetailsView(user: user),
                                      ),
                                    );
                                  }),
                                  DataCell(Text(user.name), onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDetailsView(user: user),
                                      ),
                                    );
                                  }),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _deleteUser(user.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.blueGrey),
                        dataRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.grey.shade200),
                        dataRowMaxHeight: 60,
                        headingTextStyle: const TextStyle(
                          fontSize: 18,
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
          ],
        ),
      ),
    );
  }
}
