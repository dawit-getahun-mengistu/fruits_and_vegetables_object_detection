import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruits_and_vegetables_object_detection/controller/scan_controller.dart';
import 'package:get/get.dart';

import 'image_view.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    XFile picture;
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Stack(
                    children: [
                      SizedBox(
                          height: double.infinity,
                          child: CameraPreview(controller.cameraController)),
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
                      ...controller.displayBoxesAroundRecognizedObjects(size),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              BuildContext currentcontext = context;

                              if (!controller.isCameraInitialized()) {
                                return;
                              }
                              if (controller
                                  .cameraController.value.isTakingPicture) {
                                return;
                              }
                              try {
                                await controller.cameraController
                                    .setFlashMode(FlashMode.off);
                                picture = await controller.cameraController
                                    .takePicture();

                                // await controller
                                // .predictOnImage(File(picture.path));
                                // create another screen to display image
                                // ignore: use_build_context_synchronously
                                await Navigator.push(
                                  currentcontext,
                                  MaterialPageRoute(
                                      builder: (context) => ImagePreview(
                                          file: picture,
                                          vision: controller.vision
                                          // controller.onImageResults,
                                          )),
                                );
                              } on CameraException catch (e) {
                                debugPrint(
                                    "Error occured while taking picture: $e ");
                                return;
                              }
                            },
                            child: Center(
                              child: Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.white60, width: 5),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),

                              //   child: Container(
                              //     margin: const EdgeInsets.all(20.0),
                              //     child: MaterialButton(
                              //       onPressed: () async {
                              //         BuildContext currentcontext = context;

                              //         if (!controller.isCameraInitialized()) {
                              //           return;
                              //         }
                              //         if (controller
                              //             .cameraController.value.isTakingPicture) {
                              //           return;
                              //         }
                              //         try {
                              //           await controller.cameraController
                              //               .setFlashMode(FlashMode.auto);
                              //           picture = await controller.cameraController
                              //               .takePicture();
                              //           // create another screen to display image
                              //           // ignore: use_build_context_synchronously
                              //           Navigator.push(
                              //             currentcontext,
                              //             MaterialPageRoute(
                              //               builder: (context) =>
                              //                   ImagePreview(picture),
                              //             ),
                              //           );
                              //         } on CameraException catch (e) {
                              //           debugPrint(
                              //               "Error occured while taking picture: $e ");
                              //           return;
                              //         }
                              //       },
                              //       color: Colors.white,
                              //       child: const Text('Take a picture'),
                              //     ),
                              //   ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                : const Center(child: Text("Loading Preview..."));
          }),
    );
  }
}
