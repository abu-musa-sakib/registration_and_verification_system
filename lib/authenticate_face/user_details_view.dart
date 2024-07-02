import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/common/utils/extensions/size_extension.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:registration_and_verification_system/model/user.dart';
import 'package:intl/intl.dart';

class UserDetailsView extends StatelessWidget {
  final dynamic user; // This can be either UserModel or User

  const UserDetailsView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user is UserModel) {
      return _buildUserModelDetails(context, user as UserModel);
    } else if (user is User) {
      return _buildUserDetails(context, user as User);
    } else {
      return _buildNoUserData(context);
    }
  }

  Widget _buildUserModelDetails(BuildContext context, UserModel userModel) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appBarColor,
          title: const Text("Authenticated!!!"),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: primaryWhite,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: accentColor,
                    child: Icon(
                      Icons.check,
                      color: primaryWhite,
                      size: 44,
                    ),
                  ),
                ),
                SizedBox(height: 0.025.sh),
                Text(
                  "Hey ${userModel.name} !",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 26,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You are Successfully Authenticated !",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, User? user) {
    if (user == null) {
      _buildNoUserData(context);
    }

    Widget userImageWidget;

    if (user!.image.isNotEmpty) {
      if (user.image.startsWith('/9j/')) {
        // Base64 encoded image
        userImageWidget = CircleAvatar(
          radius: 42,
          backgroundColor: primaryWhite,
          child: CircleAvatar(
            radius: 40,
            backgroundImage:
                MemoryImage(base64Decode(user.image)),
          ),
        );
      } else {
        // File path image
        userImageWidget = CircleAvatar(
          radius: 42,
          backgroundColor: primaryWhite,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: FileImage(File(user.image)),
          ),
        );
      }
    } else {
      userImageWidget = const CircleAvatar(
        radius: 42,
        backgroundColor: primaryWhite,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: accentColor,
          child: Icon(
            Icons.person,
            color: primaryWhite,
            size: 44,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text('User Details'),
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
          child: Column(
            children: [
              const Spacer(flex: 2),
              userImageWidget,
              SizedBox(height: 0.025.sh),
              Text(
                "User: ${user.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Registered on: ${DateFormat('d MMM, yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(user.registeredOn))}",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () async {
                  await UserDatabase.instance.deleteUser(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully!'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.white,
                ),
                child: const Text('Delete User'),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildNoUserData(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: appBarColor,
      title: const Text("No User Data"),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: primaryWhite,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: accentColor,
                child: Icon(
                  Icons.error,
                  color: primaryWhite,
                  size: 44,
                ),
              ),
            ),
            SizedBox(height: 0.025.sh),
            const Text(
              "No User Data Available",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 26,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please check the user list.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
