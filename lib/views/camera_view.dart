import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruits_and_vegetables_object_detection/controller/scan_controller.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? CameraPreview(controller.cameraController)
                : const Center(child: Text("Loading Preview..."));
            ;
          }),
    );
  }
}
