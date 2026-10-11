import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captura o conteudo desenhado dentro de um RepaintBoundary (identificado
/// pela GlobalKey) e devolve os bytes de uma imagem PNG. Usado para colocar
/// os desenhos da tela (esquematico, fasores, triangulo de potencias)
/// dentro do relatorio em PDF, exatamente como aparecem para o usuario.
Future<Uint8List> capturarWidgetComoPng(GlobalKey key, {double pixelRatio = 2.5}) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Nao foi possivel capturar o desenho: widget ainda nao foi montado na tela.');
  }
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}