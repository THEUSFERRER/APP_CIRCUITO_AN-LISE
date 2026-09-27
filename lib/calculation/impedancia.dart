import 'dart:math' as math;
import 'complex.dart';

enum ElementType { resistor, indutor, capacitor, generico }

class Impedance {
  final String name;
  final Complex value;
  final ElementType type;

  const Impedance(this.name, this.value, this.type);

  @override
  String toString() => '$name = $value ohms';
}

class ImpedanceFactory {
  static Complex indutor(double frequenciaHz, double indutanciaH) {
    final xl = 2 * math.pi * frequenciaHz * indutanciaH;
    return Complex(0, xl);
  }

  static Complex capacitor(double frequenciaHz, double capacitanciaF) {
    final xc = -1 / (2 * math.pi * frequenciaHz * capacitanciaF);
    return Complex(0, xc);
  }

  static Complex resistor(double resistenciaOhms) => Complex(resistenciaOhms, 0);
}

class ImpedanceCalculator {
  static Complex serie(List<Complex> impedancias) {
    var total = const Complex(0, 0);
    for (final z in impedancias) {
      total = total + z;
    }
    return total;
  }

  static Complex paralelo(List<Complex> impedancias) {
    if (impedancias.isEmpty) return const Complex(0, 0);
    var equivalenteInverso = const Complex(0, 0);
    for (final z in impedancias) {
      equivalenteInverso = equivalenteInverso + (const Complex(1, 0) / z);
    }
    return const Complex(1, 0) / equivalenteInverso;
  }

  static Complex mistoZ1SerieZ2ParaleloZ3(Complex z1, Complex z2, Complex z3) {
    final zParalelo = paralelo([z2, z3]);
    return serie([z1, zParalelo]);
  }
}