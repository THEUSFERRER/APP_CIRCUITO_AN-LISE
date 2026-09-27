import 'dart:math' as math;
import 'complex.dart';

class CircuitResult {
  final Complex zEquivalente;
  final Complex correnteTotal;
  final Complex tensaoFonte;
  final Complex potenciaComplexa;
  final double potenciaAtiva;
  final double potenciaReativa;
  final double potenciaAparente;
  final double fatorDePotencia;
  final double anguloDefasagem;
  final String comportamento;

  const CircuitResult({
    required this.zEquivalente,
    required this.correnteTotal,
    required this.tensaoFonte,
    required this.potenciaComplexa,
    required this.potenciaAtiva,
    required this.potenciaReativa,
    required this.potenciaAparente,
    required this.fatorDePotencia,
    required this.anguloDefasagem,
    required this.comportamento,
  });
}

class CircuitSolver {
  static CircuitResult resolver({
    required Complex tensaoFonte,
    required Complex zEquivalente,
  }) {
    final corrente = tensaoFonte / zEquivalente;
    final s = tensaoFonte * corrente.conjugate;

    final p = s.re;
    final q = s.im;
    final sMag = s.magnitude;

    final anguloZ = zEquivalente.angleDeg;
    final fp = sMag == 0 ? 1.0 : p / sMag;

    String comportamento;
    if (anguloZ > 0.01) {
      comportamento = 'indutivo';
    } else if (anguloZ < -0.01) {
      comportamento = 'capacitivo';
    } else {
      comportamento = 'resistivo';
    }

    return CircuitResult(
      zEquivalente: zEquivalente,
      correnteTotal: corrente,
      tensaoFonte: tensaoFonte,
      potenciaComplexa: s,
      potenciaAtiva: p,
      potenciaReativa: q,
      potenciaAparente: sMag,
      fatorDePotencia: fp,
      anguloDefasagem: anguloZ,
      comportamento: comportamento,
    );
  }

  static Complex tensaoNoElemento(Complex correnteTotal, Complex zElemento) {
    return correnteTotal * zElemento;
  }
}