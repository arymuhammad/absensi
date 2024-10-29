// import 'package:face_camera/face_camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/absen_controller.dart';

// class FaceDetection extends GetView {
//   FaceDetection({super.key});

//   final absC = Get.put(AbsenController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     appBar: AppBar(backgroundColor: Colors.transparent,),
//       body:
//         SmartFaceCamera(
//             controller: absC.camCtrl,
//             message: 'Center your face in the square',
//             showControls: false,
//             messageBuilder: (context, face) {
//               if (face == null) {
//                 return _message('Place your face in the camera');
//               }
//               if (!face.wellPositioned) {
//                 return _message('Center your face in the square');
//               }
//               return const SizedBox.shrink();
//             })
//       ,
//     );
//   }
// }

// Widget _message(String msg) => Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
//       child: Text(msg,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//               fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
//     );

import 'dart:io';

import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/material.dart';

import 'package:face_camera/face_camera.dart';
import 'package:get/get.dart';

class FaceDetection extends StatefulWidget {
  const FaceDetection({super.key});

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  File? _capturedImage;

  late FaceCameraController controller;
  final absC = Get.put(AbsenController());
  @override
  void initState() {
    controller = FaceCameraController(
      autoCapture: true,
      enableAudio: false,
      performanceMode: FaceDetectorMode.accurate,
      defaultCameraLens: CameraLens.front,
      orientation: CameraOrientation.portraitUp,
      onCapture: (File? image) {
        absC.capturedImage = image;
        Get.back();
      },
      onFaceDetected: (Face? face) {
        //Do something
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        // appBar: AppBar(
        //   title: const Text('FaceCamera example app'),
        // ),
        children: [
          Builder(builder: (context) {
            if (_capturedImage != null) {
              return Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.file(
                      _capturedImage!,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await controller.startImageStream();
                          setState(() => _capturedImage = null);
                        },
                        child: const Text(
                          'Capture Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ))
                  ],
                ),
              );
            }
            return SmartFaceCamera(
                controller: controller,
                showControls: false,                
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the square');
                  }
                  return const SizedBox.shrink();
                });
          })
        ]);
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 105),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: Colors.redAccent[700],)),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
