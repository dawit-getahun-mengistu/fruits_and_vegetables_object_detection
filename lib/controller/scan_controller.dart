import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  Future<void> onInit() async {
    super.onInit();
    await initCamera();
    await initYoloTFLite();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    cameraController.dispose();
    // Tflite.close();
    await vision.closeYoloModel();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  late CameraImage cameraImage;

  FlutterVision vision = FlutterVision();

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var h = 0.0;
  var w = 0.0;
  var x = 0.0;
  var y = 0.0;
  var label = "";
  List<Map<String, dynamic>> yoloResults = [];
  List<Map<String, dynamic>> onImageResults = [];

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraImage = image;
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);

      update();
    } else {
      debugPrint("Permission denied");
    }
  }

  initYoloTFLite() async {
    await vision.loadYoloModel(
      labels: 'assets/yolov8_labels.txt',
      modelPath: 'assets/best_float32.tflite',
      // labels: 'assets/yolov8n_labels.txt',
      // modelPath: 'assets/yolov8n.tflite',
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false,
    );
  }

  objectDetector(CameraImage image) async {
    final result = await vision.yoloOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);

    log("result is $result");

    yoloResults = result;
    update();
    log('yoloResults is ${yoloResults.length} ${result.length}');
  }

  // predictOnImage(File picture) async {
  //   // onImageResults.clear();
  //   Uint8List byte = await picture.readAsBytes();
  //   // Uint8List byte = await imageFile!.readAsBytes();
  //   final image = await decodeImageFromList(byte);
  //   var imageHeight = image.height;
  //   var imageWidth = image.width;

  //   final result = await vision.yoloOnImage(
  //     bytesList: byte,
  //     imageHeight: image.height,
  //     imageWidth: image.width,
  //     // iouThreshold: 0.0,
  //     confThreshold: 0.4,
  //     // classThreshold: null,
  //   );

  //   log("on Image result is $result");

  //   onImageResults = result;
  //   // update();
  //   log('on Image Results is ${onImageResults.length} ${result.length} height: $imageHeight width: $imageWidth}');
  //   return onImageResults;
  // }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage.height);
    double factorY = screen.height / (cameraImage.width);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
