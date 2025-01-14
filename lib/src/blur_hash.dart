import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'common.dart';
import 'dart:ui' as ui;

class BlurData {
  final int width;
  final int height;
  final double quantised;
  final double punch;
  final double opacity;
  final List<DoubleColor> colors;

  final BlurData? mixed;
  final double? mixedT;

  const BlurData({
    required this.width,
    required this.height,
    required this.quantised,
    required this.punch,
    required this.colors,
    this.opacity = 1.0,
    this.mixed,
    this.mixedT,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is BlurData) {
      return width == other.width &&
          height == other.height &&
          quantised == other.quantised &&
          punch == other.punch &&
          opacity == other.opacity &&
          listEquals(colors, other.colors);
    }
    return false;
  }

  @override
  int get hashCode =>
      Object.hashAll([width, height, quantised, punch, ...colors]);

  @override
  String toString() {
    return 'BlurData(w: $width, h: $height, quantised: $quantised, punch: $punch, colors: $colors)';
  }

  // copy
  BlurData copyWith({
    int? width,
    int? height,
    double? quantised,
    double? punch,
    double? opacity,
    List<DoubleColor>? colors,
    BlurData? mixed,
    double? mixedT,
  }) {
    return BlurData(
      width: width ?? this.width,
      height: height ?? this.height,
      quantised: quantised ?? this.quantised,
      punch: punch ?? this.punch,
      opacity: opacity ?? this.opacity,
      colors: colors ?? this.colors,
      mixed: mixed ?? this.mixed,
      mixedT: mixedT ?? this.mixedT,
    );
  }

  BlurData lerp(BlurData end, double t) {
    if (t == 1) return end;
    if (width != end.width || height != end.height) {
      if (mixed != null && mixed != end) {
        return mixed!.lerp(end, t);
      }
      return copyWith(
        mixed: end,
        mixedT: t,
      );
    }
    return BlurData(
      width: lerpDouble(width, end.width, t)!.toInt(),
      height: lerpDouble(height, end.height, t)!.toInt(),
      quantised: lerpDouble(quantised, end.quantised, t)!,
      punch: lerpDouble(punch, end.punch, t)!,
      opacity: lerpDouble(opacity, end.opacity, t)!,
      colors: List.generate(
        colors.length,
        (i) => colors[i].lerp(
          end.colors[i],
          t,
        ),
      ),
    );
  }

  void paint(Canvas canvas, Rect rect, ui.FragmentShader shader,
      {double o = 1.0}) {
    shader.setFloat(0, rect.left);
    shader.setFloat(1, rect.top);
    shader.setFloat(2, rect.width);
    shader.setFloat(3, rect.height);
    shader.setFloat(4, width.toDouble());
    shader.setFloat(5, height.toDouble());

    final l = max(64, colors.length);
    for (int i = 0; i < l; i++) {
      if (i < colors.length) {
        final color = colors[i];
        shader.setFloat(6 + i * 3, color.r);
        shader.setFloat(7 + i * 3, color.g);
        shader.setFloat(8 + i * 3, color.b);
      } else {
        shader.setFloat(6 + i * 3, 0);
        shader.setFloat(7 + i * 3, 0);
        shader.setFloat(8 + i * 3, 0);
      }
    }
    final Paint paint = Paint();
    paint.color = Color.fromRGBO(0, 0, 0, opacity * o * (1 - (mixedT ?? 0)));
    paint.shader = shader;
    paint.isAntiAlias = true;

    canvas.drawRect(rect, paint);

    if (mixed != null) {
      mixed!.paint(canvas, rect, shader, o: mixedT ?? 1);
    }
  }
}

class BlurHash extends StatefulWidget {
  final String hash;
  final double punch;
  final Widget? child;

  const BlurHash(
    this.hash, {
    this.punch = 1.0,
    this.child,
    super.key,
  });

  static const _shader64 = 'packages/blurhash_shader/shaders/blurhash_64.frag';
  static final Map<String, BlurData> _blurHashDataCache = {};

  static ui.FragmentProgram? _fragmentProgram;

  static Future loadShader() async {
    _fragmentProgram ??= await ui.FragmentProgram.fromAsset(_shader64);
  }

  static ui.FragmentShader getShader() {
    if (_fragmentProgram == null) {
      throw Exception(
          'BlurHashShader not loaded, please call await BlurHash.loadShader() in the main function');
    }
    return _fragmentProgram!.fragmentShader();
  }

  static BlurData decode(String blurHash, {double punch = 1.0}) {
    final key = '$blurHash-$punch';
    if (_blurHashDataCache.containsKey(key)) {
      return _blurHashDataCache[key]!;
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
    final data = BlurData(
      width: numX,
      height: numY,
      quantised: maximumValue,
      punch: punch,
      colors: colors,
    );
    _blurHashDataCache[key] = data;
    return data;
  }

  @override
  State<BlurHash> createState() => _BlurHashState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('hash', hash));
    properties.add(DiagnosticsProperty<double>('punch', punch));
  }
}

class _BlurHashState extends State<BlurHash> {
  final shader = BlurHash.getShader();

  @override
  void dispose() {
    shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = BlurHash.decode(widget.hash, punch: widget.punch);
    return CustomPaint(
      isComplex: true,
      willChange: false,
      painter: BlurHashPainter(data, shader),
      child: widget.child,
    );
  }
}

class BlurHashPainter extends CustomPainter {
  final BlurData data;
  final ui.FragmentShader shader;

  BlurHashPainter(
    this.data,
    this.shader,
  );

  @override
  void paint(Canvas canvas, Size size) {
    data.paint(
      canvas,
      Offset.zero & size,
      shader,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is BlurHashPainter) {
      return oldDelegate.data != data;
    }
    return true;
  }

  @override
  bool hitTest(Offset position) {
    return false;
  }
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
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final shader = BlurHash.getShader();
    data.paint(
        canvas, Offset.zero & Size(size.toDouble(), size.toDouble()), shader);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    shader.dispose();
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

class BlurHashDecoration extends Decoration {
  final BlurData data;
  final ShapeBorder? shape;

  BlurHashDecoration(String hash, {this.shape}) : data = BlurHash.decode(hash);

  const BlurHashDecoration.data(this.data, {this.shape});

  @override
  bool get isComplex => true;

  @override
  BlurHashDecoration? lerpFrom(Decoration? a, double t) {
    assert(debugAssertIsValid());
    if (a is BlurHashDecoration) {
      return BlurHashDecoration.data(
        a.data.lerp(data, t),
        shape: ShapeBorder.lerp(a.shape, shape, t),
      );
    }
    return this;
  }

  @override
  BlurHashDecoration? lerpTo(Decoration? b, double t) {
    assert(debugAssertIsValid());
    if (b is BlurHashDecoration) {
      return BlurHashDecoration.data(
        data.lerp(b.data, t),
        shape: ShapeBorder.lerp(shape, b.shape, t),
      );
    }
    return this;
  }

  @override
  BoxPainter createBoxPainter([void Function()? onChanged]) {
    return _BlurHashDecorationPainter(data, shape, onChanged);
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) {
    if (shape == null) return true;
    return shape!
        .getOuterPath(Offset.zero & size, textDirection: textDirection)
        .contains(position);
  }

  @override
  getClipPath(Rect rect, TextDirection textDirection) {
    if (shape == null) return Path()..addRect(rect);
    return shape!.getInnerPath(rect, textDirection: textDirection);
  }
}

class _BlurHashDecorationPainter extends BoxPainter {
  final shader = BlurHash.getShader();
  BlurData data;
  final ShapeBorder? shape;

  _BlurHashDecorationPainter(this.data, [this.shape, super.onChanged]);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & (configuration.size ?? Size.zero);
    canvas.save();
    if (shape != null) {
      shape!.paint(canvas, rect);
      canvas.clipPath(
        shape!.getInnerPath(
          rect,
          textDirection: TextDirection.ltr,
        ),
      );
    }
    data.paint(canvas, rect, shader);
    canvas.restore();
  }

  @override
  void dispose() {
    shader.dispose();
    super.dispose();
  }
}
