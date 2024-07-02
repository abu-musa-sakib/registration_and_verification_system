import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/common/utils/classes/SmartFaceCameraWidget.dart';
import 'package:registration_and_verification_system/common/utils/face_registration_util.dart';
import 'package:registration_and_verification_system/constants/theme.dart';

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
      await FaceRegistrationUtil.startRegistrationProcess(
          context, face, _image);
      setState(() {
        _isFaceDetected = false;
      });
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
                                  await FaceRegistrationUtil
                                      .startRegistrationProcess(
                                          context, faces.first, _image);
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
