import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'circuito.dart';
import 'bloco_circuito.dart';
import 'elemento_circuito.dart';
import 'complex.dart';

class ImagensRelatorio {
  final Uint8List esquematico;
  final Uint8List trianguloPotencias;
  final Uint8List fasorialGeral;
  final Uint8List fasorialTensoes;
  final Uint8List fasorialCorrentes;

  ImagensRelatorio({
    required this.esquematico,
    required this.trianguloPotencias,
    required this.fasorialGeral,
    required this.fasorialTensoes,
    required this.fasorialCorrentes,
  });
}

String _formatoDuplo(Complex v, String unidade) {
  final un = unidade.isEmpty ? '' : ' $unidade';
  return '${v.toString()}$un\n(${v.toPolarString()}$un)';
}

const _margemRelatorio = pw.EdgeInsets.only(
  left: 2 * PdfPageFormat.cm,
  top: 2 * PdfPageFormat.cm,
  right: 2 * PdfPageFormat.cm,
  bottom: 2 * PdfPageFormat.cm,
);

Future<void> exportarCircuitoParaPdf({
  required String nomeCircuito,
  required double frequencia,
  required List<BlocoCircuito> blocos,
  required CircuitResult resultado,
  required ImagensRelatorio imagens,
  List<String> autores = const [],
}) async {
  final fonteRegular = await PdfGoogleFonts.notoSansRegular();
  final fonteNegrito = await PdfGoogleFonts.notoSansBold();
  final fonteItalica = await PdfGoogleFonts.notoSansItalic();
  final fonteSimbolos = await PdfGoogleFonts.notoSansMathRegular();

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fonteRegular,
      bold: fonteNegrito,
      italic: fonteItalica,
      fontFallback: [fonteSimbolos],
    ),
  );

  final elementosFlat = <ElementoCircuito>[];
  for (final b in blocos) {
    elementosFlat.addAll(b.elementos);
  }

  final imgEsquematico = pw.MemoryImage(imagens.esquematico);
  final imgTriangulo = pw.MemoryImage(imagens.trianguloPotencias);
  final imgFasorialGeral = pw.MemoryImage(imagens.fasorialGeral);
  final imgFasorialTensoes = pw.MemoryImage(imagens.fasorialTensoes);
  final imgFasorialCorrentes = pw.MemoryImage(imagens.fasorialCorrentes);

  final ano = DateTime.now().year.toString();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: _margemRelatorio,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 20),
            pw.Text(
              'INSTITUTO FEDERAL DO MATO GROSSO',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              'CAMPUS OCTAYDE JORGE DA SILVA',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 70),
            if (autores.isNotEmpty)
              ...autores.map(
                (nome) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    nome.toUpperCase(),
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),
            pw.SizedBox(height: 90),
            pw.Text(
              'RELATORIO DE CIRCUITO EM CORRENTE ALTERNADA',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              nomeCircuito,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 90),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.SizedBox(
                width: 260,
                child: pw.Text(
                  'Relatorio tecnico gerado automaticamente pelo App de Circuitos '
                  'Eletricos em CA, apresentando a analise de um circuito em corrente '
                  'alternada: impedancias, tensoes, correntes, potencias e diagramas fasoriais.',
                  style: const pw.TextStyle(fontSize: 11),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
            ),
            pw.Spacer(),
            pw.Text('Cuiaba', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(ano, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
    ),
  );

  var numeroFigura = 0;

  pw.Widget tituloSecao(String texto) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
        child: pw.Text(
          texto,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );

  pw.Widget figuraGrande(pw.MemoryImage imagem, String titulo) {
    numeroFigura++;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Center(
          child: pw.Image(imagem, fit: pw.BoxFit.contain, width: 470, height: 470),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Figura $numeroFigura - $titulo',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Fonte: elaborado pelo autor',
          style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget figuraPequena(pw.MemoryImage imagem, String titulo, double altura) {
    numeroFigura++;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Center(child: pw.Image(imagem, fit: pw.BoxFit.contain, height: altura)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Figura $numeroFigura - $titulo',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Fonte: elaborado pelo autor',
          style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.TextStyle corpo() => const pw.TextStyle(fontSize: 12);
  pw.TextStyle cabecalhoTabela() => pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
  pw.TextStyle celulaTabela() => const pw.TextStyle(fontSize: 10);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: _margemRelatorio,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.bottomRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          '${context.pageNumber}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'RELATORIO DE CIRCUITO EM CORRENTE ALTERNADA',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            nomeCircuito,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Text(
          'Frequencia: ${frequencia.toStringAsFixed(2)} Hz   |   ${blocos.length} bloco(s) em serie',
          style: corpo(),
        ),

        tituloSecao('1 ELEMENTOS DO CIRCUITO'),
        pw.Table.fromTextArray(
          headers: ['Nome', 'Tipo', 'Valor (ohms)', 'Angulo'],
          headerStyle: cabecalhoTabela(),
          cellStyle: celulaTabela(),
          cellAlignment: pw.Alignment.centerLeft,
          data: elementosFlat
              .map((e) => [
                    e.nome,
                    e.nomeTipo,
                    e.valorOhms.toStringAsFixed(2),
                    '${e.angulo.toStringAsFixed(0)} graus',
                  ])
              .toList(),
        ),

        tituloSecao('2 ESQUEMATICO'),
        figuraPequena(imgEsquematico, 'Esquematico do circuito', 260),

        tituloSecao('3 RESULTADOS GERAIS'),
        pw.Bullet(text: 'Impedancia equivalente: ${_formatoDuplo(resultado.zEquivalente, "ohms")}', style: corpo()),
        pw.Bullet(text: 'Corrente total: ${_formatoDuplo(resultado.correnteTotal, "A")}', style: corpo()),
        pw.Bullet(text: 'Tensao da fonte: ${_formatoDuplo(resultado.tensaoFonte, "V")}', style: corpo()),
        pw.Bullet(text: 'Comportamento do circuito: ${resultado.comportamento}', style: corpo()),
        pw.Bullet(text: 'Fator de potencia: ${resultado.fatorDePotencia.toStringAsFixed(3)}', style: corpo()),
        pw.Bullet(text: 'Defasagem: ${resultado.anguloDefasagem.toStringAsFixed(2)} graus', style: corpo()),

        tituloSecao('4 TRIANGULO DE POTENCIAS'),
        figuraPequena(imgTriangulo, 'Triangulo de potencias', 280),
        pw.Bullet(text: 'Potencia ativa (P): ${resultado.potenciaAtiva.toStringAsFixed(2)} W', style: corpo()),
        pw.Bullet(text: 'Potencia reativa (Q): ${resultado.potenciaReativa.toStringAsFixed(2)} var', style: corpo()),
        pw.Bullet(text: 'Potencia aparente (S): ${resultado.potenciaAparente.toStringAsFixed(2)} VA', style: corpo()),

        tituloSecao('5 DIAGRAMA FASORIAL GERAL'),
        figuraGrande(imgFasorialGeral, 'Diagrama fasorial geral'),

        tituloSecao('6 DIAGRAMA FASORIAL DAS TENSOES'),
        figuraGrande(imgFasorialTensoes, 'Diagrama fasorial das tensoes'),

        tituloSecao('7 DIAGRAMA FASORIAL DAS CORRENTES'),
        figuraGrande(imgFasorialCorrentes, 'Diagrama fasorial das correntes'),

        tituloSecao('8 TENSAO E CORRENTE EM CADA ELEMENTO'),
        pw.Table.fromTextArray(
          headers: ['Elemento', 'Tensao (V)', 'Corrente (A)'],
          headerStyle: cabecalhoTabela(),
          cellStyle: celulaTabela(),
          cellAlignment: pw.Alignment.centerLeft,
          data: List.generate(elementosFlat.length, (i) {
            final tensaoBloco = _tensaoDoElemento(blocos, resultado, i);
            final correnteElem = _correnteDoElemento(blocos, resultado, i);
            return [
              '${elementosFlat[i].nome} (${elementosFlat[i].nomeTipo})',
              _formatoDuplo(tensaoBloco, ''),
              _formatoDuplo(correnteElem, ''),
            ];
          }),
        ),
      ],
    ),
  );

  final bytes = await doc.save();
  await Printing.sharePdf(
    bytes: Uint8List.fromList(bytes),
    filename: '${nomeCircuito.replaceAll(' ', '_')}.pdf',
  );
}

dynamic _tensaoDoElemento(List<BlocoCircuito> blocos, CircuitResult resultado, int indiceGlobal) {
  var contador = 0;
  for (final b in blocos) {
    final tensaoBloco = resultado.correnteTotal * b.impedancia;
    for (var i = 0; i < b.elementos.length; i++) {
      if (contador == indiceGlobal) return tensaoBloco;
      contador++;
    }
  }
  throw RangeError('indice fora do intervalo');
}

dynamic _correnteDoElemento(List<BlocoCircuito> blocos, CircuitResult resultado, int indiceGlobal) {
  var contador = 0;
  for (final b in blocos) {
    if (b.elementos.length <= 1) {
      if (contador == indiceGlobal) return resultado.correnteTotal;
      contador++;
    } else {
      final tensaoBloco = resultado.correnteTotal * b.impedancia;
      for (final e in b.elementos) {
        if (contador == indiceGlobal) return tensaoBloco / e.impedancia;
        contador++;
      }
    }
  }
  throw RangeError('indice fora do intervalo');
}