import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'common.dart';
import 'dart:ui' as ui;

class BlurHash extends StatefulWidget {
  final String hash;
  final double punch;
  final Widget? child;

  const BlurHash(this.hash, { this.punch = 1.0, this.child, super.key});

  static const _shader12 = 'packages/blurhash_shader/shaders/blurhash_12.frag';
  static const _shader64 = 'packages/blurhash_shader/shaders/blurhash_64.frag';
  static final Map<(String, double), BlurData> _blurHashDataCache = {};
  static final Map<String, ui.FragmentProgram> _shaderCache = {};
  static final Map<String, Future<ui.FragmentProgram>> _shaderCacheFuture = {};

  static Future loadShader() {
    return Future.wait([
      getShader(_shader12),
      getShader(_shader64),
    ]);
  }

  static Future<ui.FragmentShader> getShader(String assetKey) async {
    if (_shaderCache.containsKey(assetKey)) {
      return _shaderCache[assetKey]!.fragmentShader();
    }
    if (_shaderCacheFuture.containsKey(assetKey)) {
      return (await _shaderCacheFuture[assetKey]!).fragmentShader();
    }
    final shader = ui.FragmentProgram.fromAsset(assetKey);
    _shaderCacheFuture[assetKey] = shader;
    shader.then((v) {
      _shaderCache[assetKey] = v;
      _shaderCacheFuture.remove(assetKey);
    });
    return (await shader).fragmentShader();
  }

  static BlurData decode(String blurHash, {double punch = 1.0}) {
    if (_blurHashDataCache.containsKey((blurHash, punch))) {
      return _blurHashDataCache[(blurHash, punch)]!;
    }
    final sizeFlag = decode83(blurHash[0]);
    final numY = (sizeFlag ~/ 9) + 1;
    final numX = (sizeFlag % 9) + 1;
    if (blurHash.length != 4 + 2 * numX * numY) {
      throw Exception(
          'blurhash length mismatch: length is ${blurHash.length} but '
          'it should be ${4 + 2 * numX * numY}');
    }
    if (numX * numY > 64) {
      throw Exception(
          'blurhash size is too large, width * height must be <= 64');
    }
    final quantisedMaximumValue = decode83(blurHash[1]);
    final maximumValue = (quantisedMaximumValue + 1) / 166;
    final colors = List.generate(numX * numY, (i) {
      late final DoubleColor color;
      if (i == 0) {
        final value = decode83(blurHash.substring(2, 6));
        color = decodeDC(value);
      } else {
        final value = decode83(blurHash.substring(4 + i * 2, 6 + i * 2));
        color = decodeAC(value, maximumValue * punch);
      }
      return color;
    });
    final data = (
      w: numX,
      h: numY,
      quantised: maximumValue,
      punch: punch,
      colors: colors
    );
    _blurHashDataCache[(blurHash, punch)] = data;
    return data;
  }

  @override
  State<BlurHash> createState() => _BlurHashState();
}

class _BlurHashState extends State<BlurHash> {
  ui.FragmentShader? shader;

  late final BlurData data;
  late final bool small;

  @override
  void initState() {
    data = BlurHash.decode(widget.hash, punch: widget.punch);
    small = (data.w * data.h) <= 12;
    final assetKey = small ? BlurHash._shader12 : BlurHash._shader64;
    if (BlurHash._shaderCache.containsKey(assetKey)) {
      shader = BlurHash._shaderCache[assetKey]!.fragmentShader();
    } else {
      BlurHash.getShader(assetKey).then((value) {
        setState(() {
          shader = value;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (shader == null) return widget.child ?? const SizedBox.shrink();
    return CustomPaint(
      isComplex: true,
      painter: BlurHashPainter(shader!, data, maxColorSize: small ? 12 : 64),
      child: widget.child,
    );
  }
}

class BlurHashPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final BlurData data;
  final int maxColorSize;

  BlurHashPainter(this.shader, this.data, {this.maxColorSize = 64});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, data.w.toDouble());
    shader.setFloat(3, data.h.toDouble());
    final l = max(maxColorSize, data.colors.length);
    for (int i = 0; i < l; i++) {
      if (i < data.colors.length) {
        final color = data.colors[i];
        shader.setFloat(4 + i * 3, color.$1);
        shader.setFloat(5 + i * 3, color.$2);
        shader.setFloat(6 + i * 3, color.$3);
      } else {
        shader.setFloat(4 + i * 3, 0);
        shader.setFloat(5 + i * 3, 0);
        shader.setFloat(6 + i * 3, 0);
      }
    }
    final Paint paint = Paint();
    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BlurHashImageProvider extends ImageProvider<BlurHashImageProvider> {
  final String hash;
  final double punch;
  final int size;
  final double scale;

  BlurHashImageProvider(
    this.hash, {
    this.punch = 1.0,
    this.size = 64,
    this.scale = 1.0,
  });

  @override
  ImageStreamCompleter loadImage(
      BlurHashImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  Future<ImageInfo> _loadAsync(BlurHashImageProvider key) async {
    assert(key == this);
    final data = BlurHash.decode(hash, punch: punch);
    final small = (data.w * data.h) <= 12;
    final shader = await BlurHash.getShader(
        small ? BlurHash._shader12 : BlurHash._shader64);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    BlurHashPainter(shader, data, maxColorSize: small ? 12 : 64)
        .paint(canvas, Size(size.toDouble(), size.toDouble()));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    return ImageInfo(image: image, scale: key.scale);
  }

  @override
  Future<BlurHashImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BlurHashImageProvider>(this);
  }

  @override
  bool operator ==(Object other) => other.runtimeType != runtimeType
      ? false
      : other is BlurHashImageProvider &&
          other.hash == hash &&
          other.punch == punch &&
          other.size == size &&
          other.scale == scale;

  @override
  int get hashCode => Object.hash(hash, punch, size, scale);

  @override
  String toString() =>
      '$runtimeType($hash, punch: $punch, size: $size, scale: $scale)';
}
