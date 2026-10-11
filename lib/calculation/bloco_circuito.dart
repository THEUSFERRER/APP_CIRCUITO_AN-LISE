import 'complex.dart';
import 'elemento_circuito.dart';
import 'impedancia.dart';

/// Um bloco representa um trecho do circuito que fica em serie com os
/// demais blocos. Se o bloco tiver apenas 1 elemento, ele se comporta
/// como um elemento simples em serie. Se tiver mais de 1 elemento,
/// esses elementos ficam em paralelo entre si dentro do bloco.
class BlocoCircuito {
  final List<ElementoCircuito> elementos;

  BlocoCircuito({required this.elementos});

  bool get ehParalelo => elementos.length > 1;

  Complex get impedancia {
    if (elementos.isEmpty) {
      return const Complex(0, 0);
    }
    if (elementos.length == 1) {
      return elementos.first.impedancia;
    }
    return ImpedanceCalculator.paralelo(elementos.map((e) => e.impedancia).toList());
  }

  String get rotulo => elementos.map((e) => e.nome).join(' // ');
}