import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruits_and_vegetables_object_detection/controller/scan_controller.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Stack(
                    children: [
                      CameraPreview(controller.cameraController),
                      // controller.yoloResults.isNotEmpty
                      //     ? Positioned(
                      //         // top: (controller.y) * 700,
                      //         top: controller.yoloResults[0]['box'],
                      //         // right: (controller.x) * 500,
                      //         right: controller.yoloResults[0]['box'],
                      //         child: Container(
                      //           // width: controller.w * 100 * context.width / 100,
                      //           width: controller.yoloResults[0]['box'],
                      //           // height: controller.h * 100 * context.height / 100,
                      //           height: controller.yoloResults[0]['box'],
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(8),
                      //               border: Border.all(
                      //                   color: Colors.green, width: 4.0)),
                      //           child: Column(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               Container(
                      //                   color: Colors.white,
                      //                   child: Text(controller.label)),
                      //             ],
                      //           ),
                      //         ),
                      //       )
                      //     : Container(),
                      ...controller.displayBoxesAroundRecognizedObjects(size)
                    ],
                  )
                : const Center(child: Text("Loading Preview..."));
          }),
    );
  }
}
