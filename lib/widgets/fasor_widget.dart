import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../calculation/complex.dart';

class FasorItem {
  final String rotulo;
  final Complex valor;
  final Color cor;
  const FasorItem({required this.rotulo, required this.valor, required this.cor});
}

class DiagramaFasorialWidget extends StatelessWidget {
  final List<FasorItem> fasores;
  final String unidade;

  const DiagramaFasorialWidget({super.key, required this.fasores, this.unidade = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 440,
        height: 440,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: CustomPaint(
          size: const Size(420, 420),
          painter: _FasorPainter(fasores: fasores, unidade: unidade),
        ),
      ),
    );
  }
}

class _FasorPainter extends CustomPainter {
  final List<FasorItem> fasores;
  final String unidade;
  _FasorPainter({required this.fasores, required this.unidade});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = math.min(size.width, size.height) / 2 - 55;

    final eixo = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(Offset(centro.dx - raio - 15, centro.dy), Offset(centro.dx + raio + 15, centro.dy), eixo);
    canvas.drawLine(Offset(centro.dx, centro.dy - raio - 15), Offset(centro.dx, centro.dy + raio + 15), eixo);

    final anguloPaint = Paint()..color = Colors.black38;
    for (var g = 0; g < 360; g += 30) {
      final rad = g * math.pi / 180;
      final ponto = Offset(centro.dx + (raio + 15) * math.cos(rad), centro.dy - (raio + 15) * math.sin(rad));
      final tp = TextPainter(
        text: TextSpan(text: '$g\u00b0', style: const TextStyle(color: Colors.black38, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, ponto - Offset(tp.width / 2, tp.height / 2));
      canvas.drawCircle(ponto, 1.4, anguloPaint);
    }

    const comprimentoMinimo = 40.0;

    final maiorModulo = fasores.fold<double>(0, (acc, f) => math.max(acc, f.valor.magnitude));
    final escala = maiorModulo == 0 ? 1.0 : raio / maiorModulo;

    for (var i = 0; i < fasores.length; i++) {
      _desenharFasor(canvas, centro, fasores[i], escala, i, comprimentoMinimo);
    }
  }

  void _desenharFasor(Canvas canvas, Offset centro, FasorItem item, double escala, int indice, double comprimentoMinimo) {
    final valor = item.valor;
    final anguloRad = valor.angleDeg * math.pi / 180;
    var comprimento = valor.magnitude * escala;
    if (valor.magnitude > 0 && comprimento < comprimentoMinimo) {
      comprimento = comprimentoMinimo;
    }
    final ponta = Offset(
      centro.dx + comprimento * math.cos(anguloRad),
      centro.dy - comprimento * math.sin(anguloRad),
    );

    final paint = Paint()
      ..color = item.cor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(centro, ponta, paint);

    const anguloSeta = 0.3;
    const tam = 12.0;
    final p1 = Offset(
      ponta.dx - tam * math.cos(anguloRad - anguloSeta),
      ponta.dy + tam * math.sin(anguloRad - anguloSeta),
    );
    final p2 = Offset(
      ponta.dx - tam * math.cos(anguloRad + anguloSeta),
      ponta.dy + tam * math.sin(anguloRad + anguloSeta),
    );
    canvas.drawLine(ponta, p1, paint);
    canvas.drawLine(ponta, p2, paint);

    final texto = '${item.rotulo}: ${valor.magnitude.toStringAsFixed(2)} $unidade  ${valor.angleDeg.toStringAsFixed(1)}\u00b0';
    final tp = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: item.cor, fontWeight: FontWeight.bold, fontSize: 13)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 190);

    final perpendicular = anguloRad + math.pi / 2;
    final offsetLateral = 18.0 + (indice % 3) * 16.0;
    final pontoMedio = Offset(
      centro.dx + (comprimento * 0.55) * math.cos(anguloRad),
      centro.dy - (comprimento * 0.55) * math.sin(anguloRad),
    );
    final labelAnchor = Offset(
      pontoMedio.dx + offsetLateral * math.cos(perpendicular),
      pontoMedio.dy - offsetLateral * math.sin(perpendicular),
    );

    final deslocX = labelAnchor.dx > centro.dx ? 4.0 : -tp.width - 4.0;
    tp.paint(canvas, labelAnchor + Offset(deslocX, -6));
  }

  @override
  bool shouldRepaint(covariant _FasorPainter oldDelegate) => true;
}