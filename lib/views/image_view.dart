import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruits_and_vegetables_object_detection/controller/scan_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key? key,
    required this.file,
    required this.vision,
  }) : super(key: key);
  final XFile file;
  final FlutterVision vision;
  // final List<Map<String, dynamic>> prediction;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<Map<String, dynamic>> yoloResults = [];
  File? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = true;
  bool isDetecting = false;

  // final FlutterVision vision = FlutterVision();

  @override
  void initState() {
    super.initState();
    imageFile = File(widget.file.path);
    log("On Image vision before load: $widget.vision");

    loadYoloModel().then((value) {
      setState(() {
        yoloResults = [];
        isLoaded = true;
      });
    });

    log("On Image vision after load: $widget.vision");
  }

  @override
  void dispose() async {
    super.dispose();
  }

  loadYoloModel() async {
    await widget.vision.loadYoloModel(
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

  // var yoloResults = prediction;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
        // Center(
        //     child: SizedBox(
        //         height: double.infinity,
        //         child: Image.file(File(widget.file.path)))),

        // ...displayBoxes(size, widget.prediction)
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: pickImage,
                child: const Text("Pick an image"),
              ),
              ElevatedButton(
                onPressed: isDetecting
                    ? null
                    : () async {
                        setState(() {
                          isDetecting = true;
                        });

                        await yoloOnImage();

                        // await Future.delayed(const Duration(seconds: 2));

                        setState(() {
                          isDetecting = false;
                        });
                      },
                // child: const Text("Detect"),
                child: isDetecting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text("Detecting..."),
                        ],
                      )
                    : Text("Detect"),
              )
            ],
          ),
        ),
        ...displayBoxes(size),
      ],
    );
  }

  yoloOnImage() async {
    yoloResults.clear();
    Uint8List byte = await imageFile!.readAsBytes();
    final image = await decodeImageFromList(byte);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await widget.vision.yoloOnImage(
      bytesList: byte,
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.0,
      confThreshold: 0.0,
      classThreshold: 0.0,
    );

    log("On Image: $result imageHeight: $imageHeight imageWidth: $imageWidth");
    // log("On Image vision: after prediction $vision");

    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
        yoloResults.clear();
      });
    }
  }

  List<Widget> displayBoxes(Size screen) {
    if (yoloResults.isEmpty) return [];

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    return yoloResults
        .where((result) => (result['box'][4] * 100) >= 20)
        .map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY + pady,
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
