
import 'complex.dart';

enum TipoElemento { resistor, indutor, capacitor }

double anguloParaTipo(TipoElemento tipo) {
  switch (tipo) {
    case TipoElemento.resistor:
      return 0.0;
    case TipoElemento.indutor:
      return 90.0;
    case TipoElemento.capacitor:
      return -90.0;
  }
}

class ElementoCircuito {
  final String nome;
  final TipoElemento tipo;
  final double valorOhms;

  ElementoCircuito({
    required this.nome,
    required this.tipo,
    required this.valorOhms,
  });

  double get angulo => anguloParaTipo(tipo);

  Complex get impedancia => Complex.fromPolar(valorOhms, angulo);

  String get nomeTipo {
    switch (tipo) {
      case TipoElemento.resistor:
        return 'Resistor';
      case TipoElemento.indutor:
        return 'Indutor';
      case TipoElemento.capacitor:
        return 'Capacitor';
    }
  }

  String get rotuloExibicao =>
      '$nome\n${valorOhms.toStringAsFixed(2)} \u2126 \u2220 ${angulo.toStringAsFixed(0)}\u00b0';
}