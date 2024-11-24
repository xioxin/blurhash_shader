import 'dart:math';
import 'dart:ui';

class DoubleColor {
  final double r;
  final double g;
  final double b;

  const DoubleColor(this.r, this.g, this.b);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is DoubleColor) {
      return r == other.r && g == other.g && b == other.b;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([r, g, b]);

  @override
  String toString() {
    return 'DoubleColor(r: $r, g: $g, b: $b)';
  }

  DoubleColor copyWith({
    double? r,
    double? g,
    double? b,
  }) {
    return DoubleColor(
      r ?? this.r,
      g ?? this.g,
      b ?? this.b,
    );
  }

  DoubleColor lerp(DoubleColor end, double t) {
    return DoubleColor(
      lerpDouble(r, end.r, t)!,
      lerpDouble(g, end.g, t)!,
      lerpDouble(b, end.b, t)!,
    );
  }
}

int _sign(double n) => (n < 0 ? -1 : 1);

num _signPow(double val, double exp) => _sign(val) * pow(val.abs(), exp);

int decode83(String str) {
  var value = 0;
  final units = str.codeUnits;
  final digits = _digitCharacters.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final code = units.elementAt(i);
    final digit = digits.indexOf(code);
    if (digit == -1) {
      throw ArgumentError.value(str, 'str');
    }
    value = value * 83 + digit;
  }
  return value;
}

DoubleColor decodeDC(int value) {
  final intR = value >> 16;
  final intG = (value >> 8) & 255;
  final intB = value & 255;
  return DoubleColor(
      sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB));
}

DoubleColor decodeAC(int value, double maximumValue) {
  final quantR = (value / (19 * 19)).floor();
  final quantG = (value / 19).floor() % 19;
  final quantB = value % 19;
  final rgb = DoubleColor(
      _signPow((quantR - 9) / 9, 2.0) * maximumValue,
      _signPow((quantG - 9) / 9, 2.0) * maximumValue,
      _signPow((quantB - 9) / 9, 2.0) * maximumValue);
  return rgb;
}

double sRGBToLinear(int value) {
  final v = value / 255;
  if (v <= 0.04045) {
    return v / 12.92;
  } else {
    return pow((v + 0.055) / 1.055, 2.4) as double;
  }
}

int linearTosRGB(double value) {
  final v = max(0, min(1, value));
  if (v <= 0.0031308) {
    return (v * 12.92 * 255 + 0.5).round();
  } else {
    return ((1.055 * pow(v, 1 / 2.4) - 0.055) * 255 + 0.5).round();
  }
}

const _digitCharacters =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#\$%*+,-.:;=?@[]^_{|}~";
