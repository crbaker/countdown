// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:camera/camera.dart';

// class TextDetector extends StatefulWidget {
//   final Function(String) callback;

//   TextDetector({this.callback});

//   @override
//   State<StatefulWidget> createState() => _TextDetector();
// }

// class _TextDetector extends State<TextDetector> {
//   CameraController _cameraController;

//   bool _initComplete = false;

//   bool _detectingText = false;

//   final TextRecognizer _textRecognizer =
//       FirebaseVision.instance.textRecognizer();

//   @override
//   void initState() {
//     super.initState();
//     this._initCamera();
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   void _initCamera() async {
//     try {
//       availableCameras().then((cameras) {
//         var frontCamera = cameras
//             .firstWhere((c) => c.lensDirection == CameraLensDirection.back);
          
//         if (frontCamera != null) {
//           _cameraController =
//               CameraController(frontCamera, ResolutionPreset.high);

//           _cameraController.initialize().then((_) {
//             setState(() {
//               _initComplete = true;
//             });

// print("frontCamera.sensorOrientation");
//             print(frontCamera.sensorOrientation);

//             _cameraController.startImageStream((cameraImage) {
//               if (_cameraController.value.isStreamingImages) {
//                 if (!_detectingText) {
//                   _detectText(cameraImage);
//                 }
//               }
//             });
//           });
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   bool get _cameraReady {
//     return _cameraController != null && _cameraController.value.isInitialized;
//   }

//   Uint8List _imageFromDeviceFormat(CameraImage image) {
//     final int numBytes =
//         image.planes.fold(0, (count, plane) => count += plane.bytes.length);
//     final Uint8List allBytes = Uint8List(numBytes);

//     int nextIndex = 0;
//     for (int i = 0; i < image.planes.length; i++) {
//       allBytes.setRange(nextIndex, nextIndex + image.planes[i].bytes.length,
//           image.planes[i].bytes);
//       nextIndex += image.planes[i].bytes.length;
//     }

//     return allBytes;
//   }

//   void _detectText(CameraImage image) async {
//     _detectingText = true;

//     final Uint8List rawImage = _imageFromDeviceFormat(image);

//     try {
//       final VisionText _visionText =
//           await _textRecognizer.processImage(FirebaseVisionImage.fromBytes(
//         rawImage,
//         FirebaseVisionImageMetadata(
//             rawFormat: image.format.raw,
//             size: Size(image.width.toDouble(), image.height.toDouble()),
//             rotation: ImageRotation.rotation270,
//             planeData: image.planes
//                 .map((plane) => FirebaseVisionImagePlaneMetadata(
//                       bytesPerRow: plane.bytesPerRow,
//                       height: plane.height,
//                       width: plane.width,
//                     ))
//                 .toList()),
//       ));

//       var buffer = new StringBuffer();

//       // buffer.write(_visionText.text);

//       _visionText.blocks.forEach((f) {
//         f.lines.forEach((l) {
//           // print("Vision Text: ${l.text}");
//           // buffer.write(l.text);
//           l.elements.forEach((te) {
//             buffer.write(te.text);
//             print("Confidence: ${te.confidence}");
//             print("Vision Text: ${te.text}");
//           });
//         });
//       });

//       widget.callback(buffer.toString());

//     } catch (exception) {
//       print(exception);
//     } finally {
//       _detectingText = false;
//     }
//   }

//   Widget _defaultWidget() {
//     return Container(
//       child: Column(
//         children: <Widget>[Icon(Icons.camera)],
//       ),
//     );
//   }

//   Widget _noCameraWidget() {
//     return Container(
//       child: Column(
//         children: <Widget>[
//           Icon(Icons.camera, color: Theme.of(context).primaryColor),
//           Text(
//             "There is a problem opening the camera.",
//             style: Theme.of(context)
//                 .textTheme
//                 .subhead
//                 .copyWith(color: Theme.of(context).primaryColor),
//           ),
//           Text(
//             "This is caused by a faulty front camera or your phone is not equipt with one.",
//             style: Theme.of(context)
//                 .textTheme
//                 .subtitle
//                 .copyWith(fontStyle: FontStyle.italic),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _cameraPreviewWidget() {
//     return Stack(children: <Widget>[
//       AspectRatio(
//         aspectRatio: _cameraController.value.aspectRatio,
//         child: CameraPreview(_cameraController),
//       ),
//     ]);
//   }

//   Widget _cameraWidget() {
//     return Column(
//       children: <Widget>[_cameraPreviewWidget()],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_initComplete) {
//       return _defaultWidget();
//     }

//     if (_cameraReady) {
//       return _cameraWidget();
//     } else {
//       return _noCameraWidget();
//     }
//   }
// }
