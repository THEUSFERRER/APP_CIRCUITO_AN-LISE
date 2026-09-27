import 'package:flutter/material.dart';
import '../calculation/elemento_circuito.dart';
import '../telas/entrada_dados_tela.dart' show TipoConexao;

class EsquematicoWidget extends StatelessWidget {
  final List<ElementoCircuito> elementos;
  final TipoConexao tipoConexao;

  const EsquematicoWidget({
    super.key,
    required this.elementos,
    required this.tipoConexao,
  });

  @override
  Widget build(BuildContext context) {
    final altura = tipoConexao == TipoConexao.serie ? 200.0 : 260.0;
    return Container(
      width: double.infinity,
      height: altura,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: elementos.isEmpty
          ? const Center(child: Text('Adicione elementos para ver o esquematico', style: TextStyle(color: Colors.black38)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(60),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: CustomPaint(
                      painter: _EsquematicoPainter(elementos: elementos, tipoConexao: tipoConexao),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EsquematicoPainter extends CustomPainter {
  final List<ElementoCircuito> elementos;
  final TipoConexao tipoConexao;

  _EsquematicoPainter({required this.elementos, required this.tipoConexao});

  final Paint _linha = Paint()
    ..color = Colors.black87
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (elementos.isEmpty) return;
    switch (tipoConexao) {
      case TipoConexao.serie:
        _desenharSerie(canvas, size);
        break;
      case TipoConexao.paralelo:
        _desenharParalelo(canvas, size);
        break;
      case TipoConexao.misto:
        _desenharMisto(canvas, size);
        break;
    }
  }

  void _desenharSerie(Canvas canvas, Size size) {
    final yTop = 65.0;
    final yBottom = size.height - 35.0;
    final xEsq = 70.0;
    final xDir = size.width - 45.0;
    final n = elementos.length;

    _desenharFonteVertical(canvas, Offset(xEsq, yTop), Offset(xEsq, yBottom));

    final espacamento = (xDir - xEsq) / (n + 1);
    double xAnterior = xEsq;
    for (var i = 0; i < n; i++) {
      final cx = xEsq + espacamento * (i + 1);
      canvas.drawLine(Offset(xAnterior, yTop), Offset(cx - 30, yTop), _linha);
      _desenharSimbolo(canvas, elementos[i], Offset(cx, yTop));
      xAnterior = cx + 30;
    }
    canvas.drawLine(Offset(xAnterior, yTop), Offset(xDir, yTop), _linha);
    canvas.drawLine(Offset(xDir, yTop), Offset(xDir, yBottom), _linha);
    canvas.drawLine(Offset(xDir, yBottom), Offset(xEsq, yBottom), _linha);
  }

  void _desenharParalelo(Canvas canvas, Size size) {
    final n = elementos.length;
    final yTop = 65.0;
    final yBottom = size.height - 70.0;
    final yRetorno = size.height - 30.0;
    final xFonte = 70.0;
    final xA = 130.0;
    final xB = size.width - 110.0;
    final centroX = (xA + xB) / 2;

    _desenharFonteVertical(canvas, Offset(xFonte, yTop), Offset(xFonte, yBottom));

    canvas.drawLine(Offset(xA, yTop), Offset(xA, yBottom), _linha);
    canvas.drawLine(Offset(xB, yTop), Offset(xB, yBottom), _linha);
    canvas.drawLine(Offset(xFonte, yTop), Offset(xA, yTop), _linha);

    canvas.drawLine(Offset(xFonte, yBottom), Offset(xFonte, yRetorno), _linha);
    canvas.drawLine(Offset(xFonte, yRetorno), Offset(xB, yRetorno), _linha);
    canvas.drawLine(Offset(xB, yRetorno), Offset(xB, yBottom), _linha);

    final espV = n > 1 ? (yBottom - yTop) / (n - 1) : 0.0;
    for (var i = 0; i < n; i++) {
      final y = n > 1 ? yTop + espV * i : (yTop + yBottom) / 2;
      canvas.drawLine(Offset(xA, y), Offset(centroX - 30, y), _linha);
      canvas.drawLine(Offset(centroX + 30, y), Offset(xB, y), _linha);
      _desenharSimbolo(canvas, elementos[i], Offset(centroX, y));
    }
  }

  void _desenharMisto(Canvas canvas, Size size) {
    if (elementos.length < 3) {
      _desenharSerie(canvas, size);
      return;
    }
    final z1 = elementos[0];
    final z2 = elementos[1];
    final z3 = elementos[2];

    final xFonte = 60.0;
    final yTop = 65.0;
    final yBottom = size.height - 35.0;
    final yMeio = (yTop + yBottom) / 2;

    _desenharFonteVertical(canvas, Offset(xFonte, yTop), Offset(xFonte, yBottom));

    final xZ1 = 150.0;
    canvas.drawLine(Offset(xFonte, yTop), Offset(xZ1 - 30, yTop), _linha);
    _desenharSimbolo(canvas, z1, Offset(xZ1, yTop));

    final xA = xZ1 + 90;
    final xB = size.width - 90.0;
    final centroX = (xA + xB) / 2;
    final yRamoTop = yMeio - 30;
    final yRamoBottom = yMeio + 50;

    canvas.drawLine(Offset(xZ1 + 30, yTop), Offset(xA, yTop), _linha);
    canvas.drawLine(Offset(xA, yTop), Offset(xA, yRamoBottom), _linha);
    canvas.drawLine(Offset(xB, yRamoTop), Offset(xB, yRamoBottom), _linha);

    canvas.drawLine(Offset(xA, yRamoTop), Offset(centroX - 30, yRamoTop), _linha);
    canvas.drawLine(Offset(centroX + 30, yRamoTop), Offset(xB, yRamoTop), _linha);
    _desenharSimbolo(canvas, z2, Offset(centroX, yRamoTop));

    canvas.drawLine(Offset(xA, yRamoBottom), Offset(centroX - 30, yRamoBottom), _linha);
    canvas.drawLine(Offset(centroX + 30, yRamoBottom), Offset(xB, yRamoBottom), _linha);
    _desenharSimbolo(canvas, z3, Offset(centroX, yRamoBottom));

    canvas.drawLine(Offset(xB, yRamoBottom), Offset(xB, yBottom), _linha);
    canvas.drawLine(Offset(xB, yBottom), Offset(xFonte, yBottom), _linha);
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