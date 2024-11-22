// // import 'dart:async';
// // import 'dart:typed_data';
// // import 'dart:ui' as ui;
// // import 'package:flutter/widgets.dart';
// //
// // import 'common.dart';
// //
// // Map<(String, double), ui.Image> _imageCache = {};
// //
// // Future<ui.Image> blurHashTexture(String blurHash, {double punch = 1.0}) {
// //   if (_imageCache.containsKey((blurHash, punch))) {
// //     return Future.value(_imageCache[(blurHash, punch)]!);
// //   }
// //   final sizeFlag = decode83(blurHash[0]);
// //   final numY = (sizeFlag ~/ 9) + 1;
// //   final numX = (sizeFlag % 9) + 1;
// //   if (blurHash.length != 4 + 2 * numX * numY) {
// //     throw Exception(
// //         'blurhash length mismatch: length is ${blurHash.length} but '
// //         'it should be ${4 + 2 * numX * numY}');
// //   }
// //   final quantisedMaximumValue = decode83(blurHash[1]);
// //   final maximumValue = (quantisedMaximumValue + 1) / 166;
// //   Completer<ui.Image> completer = Completer<ui.Image>();
// //   final size = numX * numY;
// //   final buffer = Uint8List(size * 4);
// //   for (int i = 0; i < size; i++) {
// //     late final DoubleColor color;
// //     if (i == 0) {
// //       final value = decode83(blurHash.substring(2, 6));
// //       color = decodeDC(value);
// //     } else {
// //       final value = decode83(blurHash.substring(4 + i * 2, 6 + i * 2));
// //       color = decodeAC(value, maximumValue * punch);
// //     }
// //     final int x = i % numX;
// //     final int y = i ~/ numX;
// //     final int index = (x + y * numX) * 4;
// //     buffer[index] = linearTosRGB(color.$1);
// //     buffer[index + 1] = linearTosRGB(color.$2);
// //     buffer[index + 2] = linearTosRGB(color.$3);
// //     buffer[index + 3] = 255;
// //   }
// //   ui.PixelFormat pixelFormat = ui.PixelFormat.rgba8888;
// //   ui.decodeImageFromPixels(buffer, numX, numY, pixelFormat, (ui.Image result) {
// //     completer.complete(result);
// //     _imageCache[(blurHash, punch)] = result;
// //   });
// //   return completer.future;
// // }
// //
// // class BlurHash extends StatefulWidget {
// //   final String hash;
// //
// //   const BlurHash({required this.hash, super.key});
// //
// //   @override
// //   State<BlurHash> createState() => _BlurHashState();
// // }
//
// class _BlurHashState extends State<BlurHash> {
//   ui.FragmentShader? shader;
//   ui.Image? image;
//
//   static ui.FragmentShader? _shaderCache;
//
//   static Future<ui.FragmentShader> precacheShader() {
//     if (_shaderCache != null) {
//       return Future.value(_shaderCache!);
//     }
//     return ui.FragmentProgram.fromAsset(
//             'packages/blurhash_shader/shaders/blurhash.frag')
//         .then((ui.FragmentProgram program) {
//       _shaderCache = program.fragmentShader();
//       return _shaderCache!;
//     }, onError: (Object error, StackTrace stackTrace) {
//       FlutterError.reportError(
//           FlutterErrorDetails(exception: error, stack: stackTrace));
//     });
//   }
//
//   @override
//   void initState() {
//     Future.wait([blurHashTexture(widget.hash), precacheShader()]).then((value) {
//       setState(() {
//         image = value.first as ui.Image;
//         shader = value.last as ui.FragmentShader;
//       });
//     });
//     super.initState();
//   }
//
//   @override
//   void didUpdateWidget(covariant BlurHash oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.hash != widget.hash) {
//       blurHashTexture(widget.hash).then((val) {
//         setState(() {
//           image = val;
//         });
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (image == null || shader == null) return const SizedBox.shrink();
//     return CustomPaint(
//       isComplex: true,
//       painter: BlurHashPainter(shader!, image!),
//     );
//   }
// }
// //
// // class BlurHashPainter extends CustomPainter {
// //   final ui.FragmentShader shader;
// //   final ui.Image image;
// //
// //   BlurHashPainter(this.shader, this.image);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final Paint paint = Paint();
// //     shader.setFloat(0, size.width);
// //     shader.setFloat(1, size.height);
// //     shader.setFloat(2, image.width.toDouble());
// //     shader.setFloat(3, image.height.toDouble());
// //     shader.setImageSampler(0, image);
// //     paint.shader = shader;
// //     canvas.drawRect(Offset.zero & size, paint);
// //   }
// //
// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => false;
// // }
