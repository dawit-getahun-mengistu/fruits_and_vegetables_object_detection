import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
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

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = await CameraController(
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
    // await Tflite.loadModel(
    //   // model: 'assets/mobilenet_v1_1.0_224.tflite',
    //   // labels: 'assets/labels.txt',
    //   model: 'assets/mobilenet_v1_1.0_224_quant.tflite',
    //   labels: 'assets/labels_mobilenet_quant_v1_224.txt',
    //   isAsset: true,
    //   numThreads: 1,
    //   useGpuDelegate: false,
    // );
    await vision.loadYoloModel(
      // labels: 'assets/yolov8_labels.txt',
      // modelPath: 'assets/best_float32.tflite',
      labels: 'assets/yolov8n_labels.txt',
      modelPath: 'assets/yolov8n.tflite',
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false,
    );
  }

  oldobjectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    // if (detector != null) {
    //   if (detector.first['confidence'] * 100 > 45) {
    //     log("Result is ${detector.first[0]}");

    //     label = detector.first[0]['label'].toString();
    //     // h = detector.[0]['rect']['h'];
    //     // w = detector.[0]['rect']['w'];
    //     // x = detector.[0]['rect']['x'];
    //     // y = detector.[0]['rect']['y'];
    //     update();
    //     log("label: $label");
    //   }
    //   update();
    // }
    if (detector != null && detector.isNotEmpty) {
      double confidence = detector[0]['confidence'];
      String label = detector[0]['label'];

      if (confidence * 100 > 45) {
        log("{confidence: $confidence, label: $label}");

        // Set your label variable here if needed
        // label = label;

        update();
        log("label: $label");
      }
      update();
    }
  }

  objectDetector(CameraImage image) async {
    // try {
    //   // if (Tflite.anchors == null) {
    //   //   debugPrint("TensorFlow Lite interpreter not initialized.");
    //   //   return;
    //   // }

    //   var detector = await Tflite.runModelOnFrame(
    //     bytesList: image.planes.map((e) {
    //       return e.bytes;
    //     }).toList(),
    //     asynch: false,
    //     imageHeight: image.height,
    //     imageWidth: image.width,
    //     imageMean: 127.5,
    //     imageStd: 127.5,
    //     numResults: 1,
    //     rotation: 90,
    //     threshold: 0.4,
    //   );

    //   // log("Result is $detector");
    //   if (detector != null) {
    //     log("Detector is $detector");
    //     if (detector.first['confidence'] * 100 > 45) {
    //       log("Result is ${detector.first}");

    //       label = detector.first['label'].toString();
    //       // h = detector.first['rect']['h'];
    //       // w = detector.first['rect']['w'];
    //       // x = detector.first['rect']['x'];
    //       // y = detector.first['rect']['y'];
    //       update();
    //       log("label: $label");
    //     }
    //     update();
    //   }
    // } catch (e) {
    //   // log("Error in objectDetector: $e");
    // }
    final result = await vision.yoloOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);

    log("result is ${result}");

    // if (result.isNotEmpty) {
    yoloResults = result;
    update();
    // }
    update();
    log('yoloResults is ${yoloResults.length} ${result.length}');
  }

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
