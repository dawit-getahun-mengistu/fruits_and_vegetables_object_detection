import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruits_and_vegetables_object_detection/views/camera_view.dart';

void main() async {
  runApp(const MyApp());
}
// main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   runApp(
//     const MaterialApp(
//       home: MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detector',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CameraView(),
    );
  }
}
