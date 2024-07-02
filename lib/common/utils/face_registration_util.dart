import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:registration_and_verification_system/model/user_model.dart';
import 'package:registration_and_verification_system/register_face/enter_details_view.dart';

class FaceRegistrationUtil {
  static Future<void> startRegistrationProcess(
      BuildContext context, Face face, File image) async {
    // Waiting to extract face features
    try {
      // Extract face features
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );

      // Extracting face features
      FaceFeatures? faceFeatures = await extractFaceFeatures(face);
      if (context.mounted) Navigator.of(context).pop();

      // Ensure the image is updated
      await Future.delayed(const Duration(milliseconds: 500));

      if (image != File('') && faceFeatures != null) {
        // Navigate to the details view
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EnterDetailsView(
              image: image.path,
              faceFeatures: faceFeatures,
            ),
          ),
        );
      } else if (image == File('')) {
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
    } catch (e) {
      debugPrint("Error during registration process: $e");
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  static Future<FaceFeatures?> extractFaceFeatures(Face face) async {
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

  static double compareFaces(FaceFeatures face1, FaceFeatures face2) {
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

  static double euclideanDistance(Points point1, Points point2) {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
  }
}
