import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:registration_and_verification_system/model/user_model.dart';

Future<FaceFeatures?> extractFaceFeatures(InputImage inputImage, FaceDetector faceDetector) async {
  try {
    debugPrint("Starting face feature extraction...");
    List<Face> faceList = await faceDetector.processImage(inputImage);
    debugPrint("Faces detected: ${faceList.length}");

    if (faceList.isEmpty) {
      debugPrint("No faces detected");
      return null;
    }

    Face face = faceList.first;

    Points? _getPoints(FaceLandmarkType landmarkType) {
      final landmark = face.landmarks[landmarkType];
      if (landmark != null) {
        debugPrint("Landmark $landmarkType detected at (${landmark.position.x}, ${landmark.position.y})");
        return Points(
          x: landmark.position.x.toInt(),
          y: landmark.position.y.toInt(),
        );
      }
      debugPrint("Landmark $landmarkType not detected");
      return null;
    }

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
  } catch (e) {
    debugPrint("Error during face feature extraction: $e");
    return null;
  }
}

