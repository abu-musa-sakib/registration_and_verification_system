import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart';
import 'package:registration_and_verification_system/common/utils/extensions/size_extension.dart';
import 'package:registration_and_verification_system/common/utils/face_registration_util.dart';
import 'package:registration_and_verification_system/common/views/camera_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:registration_and_verification_system/authenticate_face/scanning_animation/animated_view.dart';
import 'package:registration_and_verification_system/authenticate_face/user_details_view.dart';
import 'package:registration_and_verification_system/common/utils/custom_snackbar.dart';
import 'package:registration_and_verification_system/common/utils/custom_button.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:registration_and_verification_system/common/utils/extract_face_feature.dart';

const double similarityThreshold = 0.80;

class AuthenticateFaceViewManual extends StatefulWidget {
  const AuthenticateFaceViewManual({super.key});

  @override
  State<AuthenticateFaceViewManual> createState() =>
      _AuthenticateFaceViewManualState();
}

class _AuthenticateFaceViewManualState
    extends State<AuthenticateFaceViewManual> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  bool _canAuthenticate = false;
  late Database _database;
  String _similarity = "";
  bool isMatching = false;
  int trialNumber = 1;
  UserModel? loggingUser;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  @override
  void dispose() {
    _faceDetector.close();
    _database.close();
    super.dispose();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, image TEXT, faceFeatures TEXT, registeredOn INTEGER)",
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Authenticate Face"),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 0.82.sh,
                      width: double.infinity,
                      padding:
                          EdgeInsets.fromLTRB(0.05.sw, 0.025.sh, 0.05.sw, 0),
                      decoration: BoxDecoration(
                        color: overlayContainerClr,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.03.sh),
                          topRight: Radius.circular(0.03.sh),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CameraView(
                                onImage: (image) {
                                  _setImage(image);
                                },
                                onInputImage: (inputImage) async {
                                  setState(() => isMatching = true);
                                  _faceFeatures = await extractFaceFeatures(
                                      inputImage, _faceDetector);
                                  setState(() => isMatching = false);
                                },
                              ),
                              if (isMatching)
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0.064.sh),
                                    child: const AnimatedView(),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (_canAuthenticate)
                            CustomButton(
                              text: "Authenticate",
                              onTap: () {
                                setState(() => isMatching = true);
                                _fetchUsersAndMatchFace(context);
                              },
                            ),
                          SizedBox(height: 0.038.sh),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _setImage(Uint8List imageToAuthenticate) async {
    setState(() {
      _canAuthenticate = true;
    });
  }

  void _fetchUsersAndMatchFace(BuildContext context) async {
    try {
      final users = await _database.rawQuery('SELECT * FROM users');

      if (users.isNotEmpty) {
        final filteredUsers = <UserModel>[];

        for (var user in users) {
          final userModel = UserModel.fromJson(user);
          final similarity = FaceRegistrationUtil.compareFaces(
              _faceFeatures!, userModel.faceFeatures!);
          if (similarity >= 0.8 && similarity <= 1.5) {
            filteredUsers.add(userModel);
          }
        }

        filteredUsers.sort((a, b) =>
            FaceRegistrationUtil.compareFaces(_faceFeatures!, a.faceFeatures!)
                .compareTo(FaceRegistrationUtil.compareFaces(
                    _faceFeatures!, b.faceFeatures!)));

        _matchFaces(context: context, users: filteredUsers);
      } else {
        _showFailureDialog(
          context,
          title: "No Users Registered",
          description:
              "Make sure users are registered first before Authenticating.",
        );
      }
    } catch (e) {
      log("Error fetching users: $e");
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }
  }

  void _matchFaces(
      {required BuildContext context, required List<UserModel> users}) async {
    bool faceMatched = false;

    for (var user in users) {
      // Face comparing logic.
      final similarity =
          FaceRegistrationUtil.compareFaces(_faceFeatures!, user.faceFeatures!);

      setState(() {
        _similarity = similarity.toStringAsFixed(2);
        log("similarity: $_similarity");

        if (similarity > similarityThreshold) {
          faceMatched = true;
          loggingUser = user;
        } else {
          faceMatched = false;
        }
      });

      if (faceMatched) {
        setState(() {
          trialNumber = 1;
          isMatching = false;
        });

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailsView(user: loggingUser!),
            ),
          );
        }
        break;
      }
    }

    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          context,
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
      } else if (trialNumber == 3) {
        setState(() {
          isMatching = false;
          trialNumber++;
        });
        _showNamePromptDialog(context);
      } else {
        setState(() => trialNumber++);
        _showFailureDialog(
          context,
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
      }
    }
  }

  void _showNamePromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Enter Name"),
          content: TextFormField(
            controller: _nameController,
            cursorColor: accentColor,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2,
                  color: accentColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2,
                  color: accentColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  CustomSnackBar.errorSnackBar("Enter a name to proceed");
                } else {
                  Navigator.of(dialogContext).pop();
                  setState(() => isMatching = true);
                  _fetchUserByName(context, _nameController.text.trim());
                }
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: accentColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _fetchUserByName(BuildContext context, String orgID) async {
    try {
      final users = await _database
          .rawQuery('SELECT * FROM users WHERE organizationId = ?', [orgID]);

      if (users.isNotEmpty) {
        final userList = users.map((user) => UserModel.fromJson(user)).toList();
        _matchFaces(context: context, users: userList);
      } else {
        setState(() => trialNumber = 1);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserDetailsView(user: null),
          ),
        );
        _showFailureDialog(
          context,
          title: "User Not Found",
          description:
              "User is not registered yet. Register first to authenticate.",
        );
      }
    } catch (e) {
      log("Error fetching user by name: $e");
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }
  }

  void _showFailureDialog(BuildContext context,
      {required String title, required String description}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: accentColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
