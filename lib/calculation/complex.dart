import 'dart:math' as math;

class Complex {
  final double re;
  final double im;

  const Complex(this.re, this.im);

  factory Complex.fromPolar(double magnitude, double angleDeg) {
    final angleRad = angleDeg * math.pi / 180;
    return Complex(magnitude * math.cos(angleRad), magnitude * math.sin(angleRad));
  }

  Complex operator +(Complex other) => Complex(re + other.re, im + other.im);
  Complex operator -(Complex other) => Complex(re - other.re, im - other.im);

  Complex operator *(Complex other) => Complex(
        re * other.re - im * other.im,
        re * other.im + im * other.re,
      );

  Complex operator /(Complex other) {
    final denom = other.re * other.re + other.im * other.im;
    return Complex(
      (re * other.re + im * other.im) / denom,
      (im * other.re - re * other.im) / denom,
    );
  }

  Complex get conjugate => Complex(re, -im);

  double get magnitude => math.sqrt(re * re + im * im);

  double get angleDeg => math.atan2(im, re) * 180 / math.pi;

  static Complex parallel(Complex a, Complex b) => (a * b) / (a + b);

  @override
  String toString() {
    final sign = im >= 0 ? '+' : '-';
    return '${re.toStringAsFixed(2)} $sign j${im.abs().toStringAsFixed(2)}';
  }

  String toPolarString() =>
      '${magnitude.toStringAsFixed(2)} \u2220 ${angleDeg.toStringAsFixed(2)}\u00b0';
}