import 'complex.dart';

enum TipoElemento { resistor, indutor, capacitor }

double anguloParaTipo(TipoElemento tipo) {
  switch (tipo) {
    case TipoElemento.resistor:
      return 0;
    case TipoElemento.indutor:
      return 90;
    case TipoElemento.capacitor:
      return -90;
  }
}

class ElementoCircuito {
  final String nome;
  final TipoElemento tipo;
  final double valorOhms;

  const ElementoCircuito({
    required this.nome,
    required this.tipo,
    required this.valorOhms,
  });

  double get angulo => anguloParaTipo(tipo);

  Complex get impedancia => Complex.fromPolar(valorOhms, angulo);

  String get rotuloExibicao =>
      '$nome: ${valorOhms.toStringAsFixed(1)} \u2220 ${angulo.toStringAsFixed(0)}\u00b0 \u03a9';

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
}