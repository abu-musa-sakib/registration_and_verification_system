import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';

class SmartFaceCameraWidget extends StatefulWidget {
  final void Function(Face?) onFaceDetected;
  final void Function(File?) onCapture;
  final bool autoCapture;

  const SmartFaceCameraWidget({
    Key? key,
    required this.onFaceDetected,
    required this.onCapture,
    required this.autoCapture,
  }) : super(key: key);

  @override
  _SmartFaceCameraWidgetState createState() => _SmartFaceCameraWidgetState();
}

class _SmartFaceCameraWidgetState extends State<SmartFaceCameraWidget> {
  // CameraController? _cameraController;
  // bool _isCameraInitialized = false;
  // bool _isImageStreamActive = false;

  @override
  void initState() {
    super.initState();
    // _initializeCamera();
  }

  // Future<void> _initializeCamera() async {
  //   final cameras = await availableCameras();
  //   if (cameras.isNotEmpty) {
  //     _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
  //     await _cameraController?.initialize();
  //     if (mounted) {
  //       setState(() {
  //         _isCameraInitialized = true;
  //       });
  //     }
  //   }
  // }

  // Future<void> _startImageStream() async {
  //   if (_cameraController != null && !_isImageStreamActive) {
  //     await _cameraController?.startImageStream((image) {
  //       // Image processing code here if needed
  //     });
  //     setState(() {
  //       _isImageStreamActive = true;
  //     });
  //   }
  // }

  // Future<void> _stopCamera() async {
  //   if (_cameraController != null) {
  //     if (_isImageStreamActive) {
  //       await _cameraController?.stopImageStream();
  //       if (mounted) {
  //         setState(() {
  //           _isImageStreamActive = false;
  //         });
  //       }
  //     }
  //     await _cameraController?.dispose();
  //     if (mounted) {
  //       setState(() {
  //         _cameraController = null;
  //         _isCameraInitialized = false;
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    // _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (!_isCameraInitialized) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return SmartFaceCamera(
      imageResolution: ImageResolution.medium,
      defaultCameraLens: CameraLens.front,
      enableAudio: true,
      autoCapture: widget.autoCapture,
      showControls: true,
      // enableFaceDetection: true,
      orientation: CameraOrientation.portraitUp,
      onFaceDetected: (face) async {
        widget.onFaceDetected(face);
        // if (face != null) {
        //   await _stopCamera();
        // }
      },
      onCapture: (image) async {
        widget.onCapture(image);
        // await _stopCamera();
      },
    );
  }
}
