import 'complex.dart';
import 'bloco_circuito.dart';

enum TipoFonte { tensao, corrente }

class FonteEletrica {
  final double magnitude;
  final double anguloGraus;
  const FonteEletrica({required this.magnitude, required this.anguloGraus});
}

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
  final TipoFonte tipoFonte;

  CircuitResult({
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
    required this.tipoFonte,
  });
}

class CircuitSolver {
  static CircuitResult resolver({
    required List<BlocoCircuito> blocos,
    required TipoFonte tipoFonte,
    required List<FonteEletrica> fontes,
  }) {
    var zEq = const Complex(0, 0);
    for (final b in blocos) {
      zEq = zEq + b.impedancia;
    }

    Complex tensaoFonte;
    Complex correnteTotal;

    if (tipoFonte == TipoFonte.tensao) {
      var somaTensoes = const Complex(0, 0);
      for (final f in fontes) {
        somaTensoes = somaTensoes + Complex.fromPolar(f.magnitude, f.anguloGraus);
      }
      tensaoFonte = somaTensoes;
      correnteTotal = tensaoFonte / zEq;
    } else {
      final fonte = fontes.first;
      correnteTotal = Complex.fromPolar(fonte.magnitude, fonte.anguloGraus);
      tensaoFonte = correnteTotal * zEq;
    }

    final potenciaComplexa = tensaoFonte * correnteTotal.conjugate;

    final p = potenciaComplexa.re;
    final q = potenciaComplexa.im;
    final s = potenciaComplexa.magnitude;
    final fp = s == 0 ? 1.0 : p / s;
    final anguloDefasagem = zEq.angleDeg;

    String comportamento;
    if (anguloDefasagem > 0.01) {
      comportamento = 'indutivo';
    } else if (anguloDefasagem < -0.01) {
      comportamento = 'capacitivo';
    } else {
      comportamento = 'resistivo';
    }

    return CircuitResult(
      zEquivalente: zEq,
      correnteTotal: correnteTotal,
      tensaoFonte: tensaoFonte,
      potenciaComplexa: potenciaComplexa,
      potenciaAtiva: p,
      potenciaReativa: q,
      potenciaAparente: s,
      fatorDePotencia: fp,
      anguloDefasagem: anguloDefasagem,
      comportamento: comportamento,
      tipoFonte: tipoFonte,
    );
  }

  static Complex tensaoNoElemento(Complex corrente, Complex impedancia) {
    return corrente * impedancia;
  }
}