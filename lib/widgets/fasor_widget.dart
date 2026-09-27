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
    return Container(
      width: double.infinity,
      height: 240,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            boundaryMargin: const EdgeInsets.all(60),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: CustomPaint(
                painter: _FasorPainter(fasores: fasores, unidade: unidade),
              ),
            ),
          );
        },
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
    final raio = math.min(size.width, size.height) / 2 - 45;

    final eixo = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(Offset(centro.dx - raio - 10, centro.dy), Offset(centro.dx + raio + 10, centro.dy), eixo);
    canvas.drawLine(Offset(centro.dx, centro.dy - raio - 10), Offset(centro.dx, centro.dy + raio + 10), eixo);

    final maiorModulo = fasores.fold<double>(0, (acc, f) => math.max(acc, f.valor.magnitude));
    final escala = maiorModulo == 0 ? 1.0 : raio / maiorModulo;

    for (final f in fasores) {
      _desenharFasor(canvas, centro, f, escala);
    }
  }

  void _desenharFasor(Canvas canvas, Offset centro, FasorItem item, double escala) {
    final valor = item.valor;
    final anguloRad = valor.angleDeg * math.pi / 180;
    final comprimento = valor.magnitude * escala;
    final ponta = Offset(
      centro.dx + comprimento * math.cos(anguloRad),
      centro.dy - comprimento * math.sin(anguloRad),
    );

    final paint = Paint()
      ..color = item.cor
      ..strokeWidth = 2.5;
    canvas.drawLine(centro, ponta, paint);

    const anguloSeta = 0.3;
    const tam = 10.0;
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

    final texto = '${item.rotulo}: ${valor.magnitude.toStringAsFixed(2)}$unidade \u2220 ${valor.angleDeg.toStringAsFixed(1)}\u00b0';
    final tp = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: item.cor, fontWeight: FontWeight.bold, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 160);

    final deslocX = anguloRad.abs() > math.pi / 2 ? -tp.width - 6.0 : 6.0;
    tp.paint(canvas, ponta + Offset(deslocX, -14));
  }

  @override
  bool shouldRepaint(covariant _FasorPainter oldDelegate) => true;
}