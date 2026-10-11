import 'package:flutter/material.dart';
import '../calculation/bloco_circuito.dart';
import '../calculation/elemento_circuito.dart';

class EsquematicoWidget extends StatelessWidget {
  final List<BlocoCircuito> blocos;
  final double tensaoRms;
  final double anguloFonteGraus;

  const EsquematicoWidget({
    super.key,
    required this.blocos,
    required this.tensaoRms,
    required this.anguloFonteGraus,
  });

  @override
  Widget build(BuildContext context) {
    final temAlgumParalelo = blocos.any((b) => b.ehParalelo);
    final maiorGrupo = blocos.fold<int>(1, (acc, b) => b.elementos.length > acc ? b.elementos.length : acc);
    final altura = temAlgumParalelo ? (140.0 + maiorGrupo * 55.0) : 200.0;
    final largura = 220.0 + blocos.length * 130.0;

    final temElementos = blocos.any((b) => b.elementos.isNotEmpty);

    return Container(
      width: double.infinity,
      height: altura.clamp(200.0, 620.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: !temElementos
          ? const Center(child: Text('Adicione elementos para ver o esquematico', style: TextStyle(color: Colors.black38)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  minScale: 0.4,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: SizedBox(
                    width: largura.clamp(constraints.maxWidth, 4000.0),
                    height: constraints.maxHeight,
                    child: CustomPaint(
                      painter: _EsquematicoPainter(
                        blocos: blocos,
                        tensaoRms: tensaoRms,
                        anguloFonteGraus: anguloFonteGraus,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EsquematicoPainter extends CustomPainter {
  final List<BlocoCircuito> blocos;
  final double tensaoRms;
  final double anguloFonteGraus;

  _EsquematicoPainter({
    required this.blocos,
    required this.tensaoRms,
    required this.anguloFonteGraus,
  });

  final Paint _linha = Paint()
    ..color = Colors.black87
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final blocosValidos = blocos.where((b) => b.elementos.isNotEmpty).toList();
    if (blocosValidos.isEmpty) return;

    final xFonte = 60.0;
    final yTop = 65.0;
    final yBottom = size.height - 35.0;
    final yMeio = (yTop + yBottom) / 2;

    _desenharFonteVertical(canvas, Offset(xFonte, yTop), Offset(xFonte, yBottom));
    _desenharRotuloFonte(canvas, Offset(xFonte, yMeio));

    final n = blocosValidos.length;
    final larguraUtil = size.width - xFonte - 60.0;
    final passo = larguraUtil / n;

    double xAtual = xFonte;
    for (var i = 0; i < n; i++) {
      final centroX = xFonte + passo * (i + 0.5) + 30;
      _desenharBloco(canvas, blocosValidos[i], centroX, yTop, yBottom, xAtual);
      xAtual = centroX + 60;
    }

    canvas.drawLine(Offset(xAtual, yTop), Offset(size.width - 40, yTop), _linha);
    canvas.drawLine(Offset(size.width - 40, yTop), Offset(size.width - 40, yBottom), _linha);
    canvas.drawLine(Offset(size.width - 40, yBottom), Offset(xFonte, yBottom), _linha);
  }

  void _desenharBloco(Canvas canvas, BlocoCircuito bloco, double centroX, double yTop, double yBottom, double xEntradaFioAnterior) {
    canvas.drawLine(Offset(xEntradaFioAnterior, yTop), Offset(centroX - 30, yTop), _linha);

    if (!bloco.ehParalelo) {
      _desenharSimbolo(canvas, bloco.elementos.first, Offset(centroX, yTop));
      return;
    }

    final n = bloco.elementos.length;
    final yMeio = (yTop + yBottom) / 2;
    final alturaDisponivel = (yBottom - yTop) - 40;
    final espV = n > 1 ? alturaDisponivel / (n - 1) : 0.0;
    final yInicio = yTop + 20;

    final xA = centroX - 45;
    final xB = centroX + 45;

    canvas.drawLine(Offset(centroX - 30, yTop), Offset(xA, yTop), _linha);

    final yPrimeiro = yInicio;
    final yUltimo = n > 1 ? yInicio + espV * (n - 1) : yInicio;
    canvas.drawLine(Offset(xA, yTop), Offset(xA, yUltimo), _linha);
    canvas.drawLine(Offset(xB, yTop), Offset(xB, yUltimo), _linha);

    for (var i = 0; i < n; i++) {
      final y = n > 1 ? yInicio + espV * i : yMeio;
      canvas.drawLine(Offset(xA, y), Offset(centroX - 30, y), _linha);
      canvas.drawLine(Offset(centroX + 30, y), Offset(xB, y), _linha);
      _desenharSimbolo(canvas, bloco.elementos[i], Offset(centroX, y));
    }

    canvas.drawLine(Offset(xB, yTop), Offset(centroX + 30, yTop), _linha);
  }

  void _desenharFonteVertical(Canvas canvas, Offset topo, Offset base) {
    final centro = Offset(topo.dx, (topo.dy + base.dy) / 2);
    canvas.drawLine(topo, Offset(centro.dx, centro.dy - 18), _linha);
    canvas.drawLine(Offset(centro.dx, centro.dy + 18), base, _linha);
    canvas.drawCircle(centro, 18, _linha);
    final tp = TextPainter(
      text: const TextSpan(text: '~', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centro - Offset(tp.width / 2, tp.height / 2));
  }

  void _desenharRotuloFonte(Canvas canvas, Offset centro) {
    final texto = '${tensaoRms.toStringAsFixed(2)} V \u2220 ${anguloFonteGraus.toStringAsFixed(0)}\u00b0';
    final tp = TextPainter(
      text: TextSpan(text: texto, style: const TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 110);
    tp.paint(canvas, Offset(centro.dx - tp.width / 2, centro.dy + 24));
  }

  void _desenharSimbolo(Canvas canvas, ElementoCircuito elemento, Offset centro) {
    switch (elemento.tipo) {
      case TipoElemento.resistor:
        _desenharResistor(canvas, centro);
        break;
      case TipoElemento.indutor:
        _desenharIndutor(canvas, centro);
        break;
      case TipoElemento.capacitor:
        _desenharCapacitor(canvas, centro);
        break;
    }
    _desenharRotulo(canvas, elemento.rotuloExibicao, centro);
  }

  void _desenharResistor(Canvas canvas, Offset centro) {
    final path = Path();
    final x0 = centro.dx - 30;
    final y = centro.dy;
    path.moveTo(x0, y);
    path.lineTo(x0 + 6, y);
    final passos = [-10.0, 10.0, -10.0, 10.0, -10.0, 10.0];
    var x = x0 + 6;
    for (var i = 0; i < passos.length; i++) {
      final nx = x + 8;
      path.lineTo(nx, y + passos[i]);
      x = nx;
    }
    path.lineTo(x + 6, y);
    canvas.drawPath(path, _linha);
  }

  void _desenharIndutor(Canvas canvas, Offset centro) {
    final y = centro.dy;
    final x0 = centro.dx - 30;
    canvas.drawLine(Offset(x0, y), Offset(x0 + 6, y), _linha);
    var x = x0 + 6;
    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromCenter(center: Offset(x + 8, y - 8), width: 16, height: 16);
      canvas.drawArc(rect, 3.14159, 3.14159, false, _linha);
      x += 16;
    }
    canvas.drawLine(Offset(x, y), Offset(x + 6, y), _linha);
  }

  void _desenharCapacitor(Canvas canvas, Offset centro) {
    final y = centro.dy;
    final x0 = centro.dx - 30;
    canvas.drawLine(Offset(x0, y), Offset(centro.dx - 6, y), _linha);
    canvas.drawLine(Offset(centro.dx - 6, y - 16), Offset(centro.dx - 6, y + 16), _linha);
    canvas.drawLine(Offset(centro.dx + 6, y - 16), Offset(centro.dx + 6, y + 16), _linha);
    canvas.drawLine(Offset(centro.dx + 6, y), Offset(centro.dx + 30, y), _linha);
  }

  void _desenharRotulo(Canvas canvas, String texto, Offset centro) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: const TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 140);
    tp.paint(canvas, Offset(centro.dx - tp.width / 2, centro.dy - 45));
  }

  @override
  bool shouldRepaint(covariant _EsquematicoPainter oldDelegate) => true;
}
