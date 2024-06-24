import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraControllerProvider with ChangeNotifier {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;

  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;

  Future<void> initializeCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;

    // Request camera permissions
    final status = await Permission.camera.request();

    if (status.isGranted) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
          await _cameraController?.initialize();
          _isCameraInitialized = true;
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Camera initialization error: $e");
      }
    } else {
      debugPrint("Camera permission denied");
    }

    _isInitializing = false;
  }

  Future<void> stopCamera() async {
    if (_cameraController != null) {
      await _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopCamera();
    super.dispose();
  }
}
