// lib/authenticate_face/authenticate_face_view_auto.dart
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:registration_and_verification_system/authenticate_face/user_details_view.dart';
import 'package:registration_and_verification_system/common/utils/classes/SmartFaceCameraWidget.dart';
import 'package:registration_and_verification_system/common/utils/custom_snackbar.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

import '../common/utils/classes/context_provider.dart';

const double similarityThreshold = 1.80;

class AuthenticateFaceViewAuto extends StatefulWidget {
  const AuthenticateFaceViewAuto({super.key});

  @override
  _AuthenticateFaceViewAutoState createState() =>
      _AuthenticateFaceViewAutoState();
}

class _AuthenticateFaceViewAutoState extends State<AuthenticateFaceViewAuto> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _isMatching = false;
  List<UserModel> _registeredUsers = [];
  final CameraController _cameraController = CameraController(
    const CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
    ResolutionPreset.high,
  );
  // final StreamController<Uint8List> _imageStreamController =
  //     StreamController<Uint8List>();
  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;
  late final InputImageFormat inputImageFormat;
  late final Size imageSize;
  late final int bytesPerRow;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int trialNumber = 1;
  String _similarity = "";
  late Database _database;
  final TextEditingController _nameController = TextEditingController();

  CameraImage? _latestCameraImage;
  InputImage? _latestInputImage;
  InputImageMetadata metadata = InputImageMetadata(
    size: const Size(640.0, 480.0),
    rotation: InputImageRotation.rotation0deg,
    format: InputImageFormat.nv21,
    bytesPerRow: 640,
  );

  bool _isCameraStopped = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _initializeMetadata();
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        _currentOrientation = _getDeviceOrientationFromAccelerometer(event);
      });
    });
  }

  // Stream<Uint8List> get imageStream => _imageStreamController.stream;

  Future<void> _initializeMetadata() async {
    if (_latestInputImage?.bytes != null) {
      final bytes = _latestInputImage?.bytes!;
      final WriteBuffer buffer = WriteBuffer();
      buffer.putUint8List(bytes!);

      metadata = InputImageMetadata(
        size: imageSize,
        rotation: _getImageRotation(),
        format: inputImageFormat,
        bytesPerRow: bytesPerRow,
      );
    }
  }

  DeviceOrientation _getDeviceOrientationFromAccelerometer(
      AccelerometerEvent event) {
    if (event.x.abs() > event.y.abs()) {
      // Landscape
      if (event.x > 0) {
        return DeviceOrientation.landscapeRight;
      } else {
        return DeviceOrientation.landscapeLeft;
      }
    } else {
      // Portrait
      if (event.y > 0) {
        return DeviceOrientation.portraitUp;
      } else {
        return DeviceOrientation.portraitDown;
      }
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    _cameraController.dispose();
    _accelerometerSubscription?.cancel();
    // _imageStreamController.close();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    try {
      // Open the database
      _database = await openDatabase(
        join(await getDatabasesPath(), 'user_database.db'),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, image TEXT, faceFeatures TEXT, registeredOn INTEGER)",
          );
        },
        version: 1,
      );

      // Fetch registered users from the database
      final List<Map<String, dynamic>> users =
          await _database.rawQuery('SELECT * FROM users');

      // Convert fetched users to UserModel objects and set _registeredUsers
      _registeredUsers = users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  InputImageRotation _getImageRotation() {
    final sensorOrientation = _cameraController.description.sensorOrientation;
    final deviceOrientation = _getDeviceOrientationAngle();

    // Convert the sensor orientation and device orientation to the appropriate rotation
    final rotationCompensation = (sensorOrientation + deviceOrientation) % 360;

    switch (rotationCompensation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  int _getDeviceOrientationAngle() {
    switch (_currentOrientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
      default:
        return 0;
    }
  }

  Future<InputImage> _convertCameraImageToInputImage(
      CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    // Emit the Uint8List to the stream
    // _imageStreamController.add(bytes);
    imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
    final imageRotation = _getImageRotation();

    inputImageFormat = InputImageFormat.values.firstWhere(
      (format) => format.rawValue == cameraImage.format.raw,
      orElse: () => InputImageFormat.nv21,
    );

    bytesPerRow = cameraImage.planes.first.bytesPerRow;

    metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<List<Face>> _processInputImage(InputImage inputImage) async {
    if (_isMatching) return []; // Skip processing if already matching

    setState(() => _isMatching = true);

    try {
      // Detect faces in the InputImage
      List<Face> faces = await _faceDetector.processImage(inputImage);

      // Extract face features and compare with registered users
      if (faces.isNotEmpty) {
        setState(() {});
      } else {
        debugPrint("No faces detected in the input image.");
      }

      return faces;
    } catch (e) {
      debugPrint("Error processing input image: $e");
      return [];
    } finally {
      if (mounted) {
        setState(() => _isMatching = false);
      }
    }
  }

  Future<Uint8List> cameraImageToBytes(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<FaceFeatures?> _extractFaceFeatures(Face face) async {
    // Helper function to get points from face landmarks
    Points? _getPoints(FaceLandmarkType landmarkType) {
      final landmark = face.landmarks[landmarkType];
      if (landmark != null) {
        debugPrint(
            "Landmark $landmarkType detected at (${landmark.position.x}, ${landmark.position.y})");
        return Points(
          x: landmark.position.x.toInt(),
          y: landmark.position.y.toInt(),
        );
      }
      debugPrint("Landmark $landmarkType not detected");
      return null;
    }

    // Extracting the face features
    FaceFeatures faceFeatures = FaceFeatures(
      rightEar: _getPoints(FaceLandmarkType.rightEar),
      leftEar: _getPoints(FaceLandmarkType.leftEar),
      rightMouth: _getPoints(FaceLandmarkType.rightMouth),
      leftMouth: _getPoints(FaceLandmarkType.leftMouth),
      rightEye: _getPoints(FaceLandmarkType.rightEye),
      leftEye: _getPoints(FaceLandmarkType.leftEye),
      rightCheek: _getPoints(FaceLandmarkType.rightCheek),
      leftCheek: _getPoints(FaceLandmarkType.leftCheek),
      noseBase: _getPoints(FaceLandmarkType.noseBase),
      bottomMouth: _getPoints(FaceLandmarkType.bottomMouth),
    );

    debugPrint("Extracted Face Features: $faceFeatures");
    return faceFeatures;
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

  Future<CameraImage> _captureImageFromCamera() async {
    if (_latestCameraImage == null) {
      throw Exception('No image captured from the camera stream');
    }
    return _latestCameraImage!;
  }

  Future<FaceFeatures?> _getCurrentFaceFeatures() async {
    try {
      // Step 1: Capture an image from the camera
      final cameraImage = await _captureImageFromCamera();

      // Step 2: Convert the captured image to an InputImage
      final inputImage = await _convertCameraImageToInputImage(cameraImage);

      // Step 3: Detect faces in the InputImage
      List<Face> faces = await _faceDetector.processImage(inputImage);

      // Step 4: Extract face features from the first detected face
      if (faces.isNotEmpty) {
        return await _extractFaceFeatures(faces.first);
      } else {
        // Handle case where no faces are detected
        debugPrint("No faces detected in the captured image.");
        return null;
      }
    } catch (e) {
      debugPrint("Error getting current face features: $e");
      return null;
    }
  }

  void _fetchUserByName(BuildContext context, String orgID) async {
    try {
      final users = await _database
          .rawQuery('SELECT * FROM users WHERE organizationId = ?', [orgID]);

      if (users.isNotEmpty) {
        final userList = users.map((user) => UserModel.fromJson(user)).toList();
        setState(() {
          _registeredUsers = userList;
        });

        FaceFeatures? currentFaceFeatures = await _getCurrentFaceFeatures();
        if (currentFaceFeatures != null) {
          _fetchUsersAndMatchFace(context, currentFaceFeatures);
        } else {
          debugPrint("Failed to extract current face features.");
          _showFailureDialog(
            context,
            title: "Face Feature Extraction Failed",
            description: "Unable to extract face features. Please try again.",
          );
        }
      } else {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          context,
          title: "User Not Found",
          description:
              "User is not registered yet. Register first to authenticate.",
        );
      }
    } catch (e) {
      debugPrint("Error fetching user by name: $e");
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }
  }

  void _fetchUsersAndMatchFace(
      BuildContext context, FaceFeatures faceFeatures) async {
    try {
      final users = await _database.rawQuery('SELECT * FROM users');

      if (users.isNotEmpty) {
        final filteredUsers = <UserModel>[];

        for (var user in users) {
          final userModel = UserModel.fromJson(user);
          final similarity =
              compareFaces(faceFeatures, userModel.faceFeatures!);
          if (similarity >= 0.8 && similarity <= 1.5) {
            filteredUsers.add(userModel);
          }
        }

        filteredUsers.sort((a, b) => compareFaces(faceFeatures, a.faceFeatures!)
            .compareTo(compareFaces(faceFeatures, b.faceFeatures!)));

        if (filteredUsers.isNotEmpty) {
          final bestMatchUser = filteredUsers.first;
          setState(() {
            _similarity =
                compareFaces(faceFeatures, bestMatchUser.faceFeatures!)
                    .toStringAsFixed(2);
            trialNumber = 1;
            _isMatching = false;
          });

          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailsView(user: bestMatchUser),
              ),
            );
          }
        } else {
          _showFailureDialog(
            context,
            title: "No Matching User Found",
            description: "No users match the detected face. Please try again.",
          );
        }
      } else {
        _showFailureDialog(
          context,
          title: "No Users Registered",
          description:
              "Make sure users are registered first before Authenticating.",
        );
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
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
                  setState(() => _isMatching = true);
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

  Future<void> _stopCamera() async {
    if (_cameraController.value.isStreamingImages) {
      await _cameraController.stopImageStream();
    }
    await _cameraController.dispose();
    setState(() {}); // Update the UI to reflect that the camera is stopped
  }

  void _matchFaceWithRegisteredUsers(
      BuildContext context, InputImage inputImage) async {
    bool faceMatched = false;
    UserModel? loggingUser;

    try {
      // Detect faces in the InputImage
      List<Face> faces = await _processInputImage(inputImage);

      if (faces.isNotEmpty) {
        // Extract features from the first detected face
        FaceFeatures? faceFeatures = await _extractFaceFeatures(faces.first);

        if (faceFeatures != null) {
          for (var user in _registeredUsers) {
            // Face comparing logic
            final similarity = compareFaces(faceFeatures, user.faceFeatures!);

            setState(() {
              _similarity = similarity.toStringAsFixed(2);
              debugPrint("similarity: $_similarity");

              if (similarity > similarityThreshold) {
                faceMatched = true;
                loggingUser = user;
                return;
              } else {
                faceMatched = false;
              }
            });

            if (faceMatched) {
              setState(() {
                trialNumber = 1;
                _isMatching = false;
              });

              await _stopCamera();

              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailsView(user: loggingUser!),
                  ),
                );
              }
              return;
            }
          }
        }
      } else {
        // Handle case where no faces are detected
        debugPrint("No faces detected in the input image.");
      }
    } catch (e) {
      debugPrint("Error processing input image: $e");
    }

    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        await _stopCamera();
        _showFailureDialog(
          context,
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
        return;
      }
    } else if (trialNumber == 3) {
      setState(() {
        _isMatching = false;
        trialNumber++;
      });
      await _stopCamera();
      _showNamePromptDialog(context);
    } else {
      setState(() => trialNumber++);
      await _stopCamera();
      _showFailureDialog(
        context,
        title: "Redeem Failed",
        description: "Face doesn't match. Please try again.",
      );
      return;
    }
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
    double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);

    double ratioEar = distEar1 / distEar2;

    double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
    double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);

    double ratioEye = distEye1 / distEye2;

    double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
    double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);

    double ratioCheek = distCheek1 / distCheek2;

    double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
    double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);

    double ratioMouth = distMouth1 / distMouth2;

    double distNoseToMouth1 =
        euclideanDistance(face1.noseBase!, face1.bottomMouth!);
    double distNoseToMouth2 =
        euclideanDistance(face2.noseBase!, face2.bottomMouth!);

    double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

    double ratio =
        (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
    debugPrint("Ratio is: $ratio");

    return ratio;
  }

  double euclideanDistance(Points point1, Points point2) {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
  }

  Future<InputImage> convertBytesToInputImage(
      Uint8List bytes,
      int width,
      int height,
      InputImageRotation rotation,
      InputImageFormat format,
      int bytesPerRow) async {
    metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _stopCameraAndNavigate(BuildContext context, Face face) async {
    // Fetch the user's face features and navigate
    final faceFeatures = await _extractFaceFeatures(face);
    if (faceFeatures != null) {
      _fetchUsersAndMatchFace(context, faceFeatures);
    }
  }

  void _onFaceDetected(BuildContext context, Face? face) async {
    if (face != null && !_isCameraStopped) {
      setState(() {
        _isCameraStopped = true;
      });
      await _stopCameraAndNavigate(context, face);
    }
  }

  @override
  Widget build(BuildContext context) {
    ContextProvider.setContext(context);
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
                      height: constraints.maxHeight * 0.82,
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth * 0.05,
                        constraints.maxHeight * 0.025,
                        constraints.maxWidth * 0.05,
                        0,
                      ),
                      decoration: BoxDecoration(
                        color: overlayContainerClr,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(constraints.maxHeight * 0.03),
                          topRight:
                              Radius.circular(constraints.maxHeight * 0.03),
                        ),
                      ),
                      child: _isCameraStopped
                          ? const Center(
                              child: Text("Face detected. Processing..."))
                          : SmartFaceCameraWidget(
                              autoCapture: false,
                              onFaceDetected: (Face? face) async {
                                if (face != null) {
                                  try {
                                    _onFaceDetected(context, face);
                                  } catch (e) {
                                    debugPrint(
                                        "Error extracting features from detected face: $e");
                                  }
                                }
                              },
                              onCapture: (File? image) async {
                                if (image != null) {
                                  // final bytes = await image.readAsBytes();
                                  // final inputImage = InputImage.fromBytes(
                                  //   bytes: bytes,
                                  //   metadata: metadata,
                                  // );
                                  final inputImage = InputImage.fromFile(image);
                                  _matchFaceWithRegisteredUsers(
                                      context, inputImage);
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
