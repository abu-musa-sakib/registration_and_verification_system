import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/common/utils/classes/SmartFaceCameraWidget.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:registration_and_verification_system/register_face/enter_details_view.dart';

class RegisterFaceViewAuto extends StatefulWidget {
  @override
  _RegisterFaceViewAutoState createState() => _RegisterFaceViewAutoState();
}

class _RegisterFaceViewAutoState extends State<RegisterFaceViewAuto> {
  bool _isFaceDetected = false;
  bool _isProcessingFace = false;
  late InputImageFormat inputImageFormat;
  late Size imageSize;
  late int bytesPerRow;
  late File _image = File('');
  FaceFeatures? _faceFeatures;
  bool _isCameraStopped = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  void _onFaceDetected(Face face) async {
    if (!_isFaceDetected) {
      setState(() {
        _isFaceDetected = true;
      });
      await _startRegistrationProcess(face);
      setState(() {
        _isFaceDetected = false;
      });
    }
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

  Future<void> _startRegistrationProcess(Face face) async {
    // Waiting to extract face features
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: accentColor,
        ),
      ),
    );

    // Extracting face features
    _faceFeatures = await _extractFaceFeatures(face);
    setState(() {});
    if (mounted) Navigator.of(context).pop();

    // Ensure the image is updated
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to the details view
    if (_image != File('') && _faceFeatures != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EnterDetailsView(
            image: _image.path,
            faceFeatures: _faceFeatures!,
          ),
        ),
      );
    } else if (_image == File('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture an image.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
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
          child: Align(
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
                        topLeft: Radius.circular(constraints.maxHeight * 0.03),
                        topRight: Radius.circular(constraints.maxHeight * 0.03),
                      ),
                    ),
                    child: _isCameraStopped
                        ? const Center(
                            child: Text("Face detected. Processing..."))
                        : SmartFaceCameraWidget(
                            autoCapture: true,
                            onFaceDetected: (Face? face) async {
                              if (face != null) {
                                try {
                                  _onFaceDetected(face);
                                } catch (e) {
                                  debugPrint(
                                      "Error extracting features from detected face: $e");
                                }
                              }
                            },
                            onCapture: (File? image) async {
                              if (image != null) {
                                if (_isProcessingFace) return;
                                _isProcessingFace = true;

                                _image = image;

                                if (mounted) setState(() {});

                                final inputImage = InputImage.fromFile(_image);

                                final faces = await _faceDetector
                                    .processImage(inputImage);

                                if (faces.isNotEmpty) {
                                  _isCameraStopped =
                                      true; // This will stop the camera
                                  setState(() {});
                                  await _startRegistrationProcess(faces.first);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No face detected. Please try again.'),
                                    ),
                                  );
                                }

                                _isProcessingFace = false;
                                setState(() {});
                              }
                            }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
