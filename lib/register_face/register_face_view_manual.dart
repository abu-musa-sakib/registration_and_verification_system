import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:registration_and_verification_system/common/utils/extensions/size_extension.dart';
import 'package:registration_and_verification_system/common/utils/extract_face_feature.dart';
import 'package:registration_and_verification_system/common/views/camera_view.dart';
import 'package:registration_and_verification_system/common/utils/custom_button.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:registration_and_verification_system/register_face/enter_details_view.dart';

class RegisterFaceViewManual extends StatefulWidget {
  const RegisterFaceViewManual({super.key});

  @override
  State<RegisterFaceViewManual> createState() => _RegisterFaceViewManualState();
}

class _RegisterFaceViewManualState extends State<RegisterFaceViewManual> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  String? _image;
  FaceFeatures? _faceFeatures;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Register User"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(0.05.sw, 0.025.sh, 0.05.sw, 0.04.sh),
                  decoration: BoxDecoration(
                    color: overlayContainerClr,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0.03.sh),
                      topRight: Radius.circular(0.03.sh),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CameraView(
                          onImage: (image) {
                            setState(() {
                              _image = base64Encode(image);
                            });
                          },
                          onInputImage: (inputImage) async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              ),
                            );
                            _faceFeatures =
                                await extractFaceFeatures(inputImage, _faceDetector);
                            setState(() {});
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_image != null)
                          CustomButton(
                            text: "Start Registering",
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EnterDetailsView(
                                    image: _image!,
                                    faceFeatures: _faceFeatures!,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
