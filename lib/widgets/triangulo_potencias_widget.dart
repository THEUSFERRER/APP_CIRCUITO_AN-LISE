import 'package:flutter/material.dart';

class TrianguloPotenciasWidget extends StatelessWidget {
  final double p;
  final double q;
  final double s;

  const TrianguloPotenciasWidget({super.key, required this.p, required this.q, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
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
                painter: _TrianguloPainter(p: p, q: q, s: s),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrianguloPainter extends CustomPainter {
  final double p;
  final double q;
  final double s;
  _TrianguloPainter({required this.p, required this.q, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final linhaP = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final linhaS = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final origem = Offset(60, size.height - 55);
    final larguraDisponivel = size.width - 110;
    final alturaDisponivel = size.height - 100;

    final escalaX = p.abs() == 0 ? 1.0 : larguraDisponivel / p.abs();
    final escalaY = q.abs() == 0 ? 1.0 : alturaDisponivel / q.abs();

    final pontoP = Offset(origem.dx + p.abs() * escalaX, origem.dy);
    final pontoQ = Offset(pontoP.dx, origem.dy - q.abs() * escalaY);

    canvas.drawLine(origem, pontoP, linhaP);
    canvas.drawLine(pontoP, pontoQ, linhaP);
    canvas.drawLine(origem, pontoQ, linhaS);

    _texto(canvas, 'P = ${p.toStringAsFixed(1)} W', Offset(origem.dx, pontoP.dy + 12));
    _texto(canvas, 'Q = ${q.toStringAsFixed(1)} var', Offset(pontoP.dx + 8, (pontoP.dy + pontoQ.dy) / 2));
    _texto(
      canvas,
      'S = ${s.toStringAsFixed(1)} VA',
      Offset((origem.dx + pontoQ.dx) / 2 - 50, (origem.dy + pontoQ.dy) / 2 - 20),
      cor: Colors.indigo,
    );
  }

  void _texto(Canvas canvas, String texto, Offset pos, {Color cor = Colors.black87}) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _TrianguloPainter oldDelegate) => true;
}