import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../calculation/complex.dart';
import '../calculation/circuito.dart';
import '../calculation/bloco_circuito.dart';
import '../calculation/elemento_circuito.dart';
import '../calculation/pdf_export.dart';
import '../calculation/circuito_serializacao.dart';
import '../calculation/captura_widget.dart';
import '../widgets/esquematico_widget.dart';
import '../widgets/fasor_widget.dart';
import '../widgets/triangulo_potencias_widget.dart';

class ResultadoScreen extends StatefulWidget {
  final String nomeCircuito;
  final double frequencia;
  final List<BlocoCircuito> blocos;
  final CircuitResult resultado;
  final List<String> autores;

  const ResultadoScreen({
    super.key,
    required this.nomeCircuito,
    required this.frequencia,
    required this.blocos,
    required this.resultado,
    this.autores = const [],
  });

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  final GlobalKey _keyEsquematico = GlobalKey();
  final GlobalKey _keyTriangulo = GlobalKey();
  final GlobalKey _keyFasorialGeral = GlobalKey();
  final GlobalKey _keyFasorialTensoes = GlobalKey();
  final GlobalKey _keyFasorialCorrentes = GlobalKey();

  bool _exportando = false;

  Color get _corComportamento {
    switch (widget.resultado.comportamento) {
      case 'indutivo':
        return const Color(0xFFFF8A3D);
      case 'capacitivo':
        return const Color(0xFFB166E0);
      default:
        return const Color(0xFF27C28B);
    }
  }

  IconData get _iconeComportamento {
    switch (widget.resultado.comportamento) {
      case 'indutivo':
        return Icons.north_east;
      case 'capacitivo':
        return Icons.south_east;
      default:
        return Icons.horizontal_rule;
    }
  }

  List<List<Complex>> get _correntesPorBloco {
    final List<List<Complex>> resultadoLista = [];
    for (final b in widget.blocos) {
      if (b.elementos.length <= 1) {
        resultadoLista.add([widget.resultado.correnteTotal]);
      } else {
        final tensaoBloco = widget.resultado.correnteTotal * b.impedancia;
        resultadoLista.add(b.elementos.map((e) => tensaoBloco / e.impedancia).toList());
      }
    }
    return resultadoLista;
  }

  List<List<Complex>> get _tensoesPorBloco {
    final List<List<Complex>> resultadoLista = [];
    for (final b in widget.blocos) {
      final tensaoBloco = widget.resultado.correnteTotal * b.impedancia;
      resultadoLista.add(List.filled(b.elementos.length, tensaoBloco));
    }
    return resultadoLista;
  }

  static const List<Color> _paletaCores = [
    Color(0xFF3A6FF7), Color(0xFF17B8A6), Color(0xFFFF8A3D), Color(0xFFB166E0), Color(0xFFE0566E), Color(0xFF4F5D75),
  ];

  Future<void> _exportarPdf() async {
    setState(() => _exportando = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final imagens = ImagensRelatorio(
        esquematico: await capturarWidgetComoPng(_keyEsquematico),
        trianguloPotencias: await capturarWidgetComoPng(_keyTriangulo),
        fasorialGeral: await capturarWidgetComoPng(_keyFasorialGeral),
        fasorialTensoes: await capturarWidgetComoPng(_keyFasorialTensoes),
        fasorialCorrentes: await capturarWidgetComoPng(_keyFasorialCorrentes),
      );

      await exportarCircuitoParaPdf(
        nomeCircuito: widget.nomeCircuito,
        frequencia: widget.frequencia,
        blocos: widget.blocos,
        resultado: widget.resultado,
        imagens: imagens,
        autores: widget.autores,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nao foi possivel gerar o PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarDados() async {
    try {
      final jsonStr = circuitoParaJson(
        nomeCircuito: widget.nomeCircuito,
        frequencia: widget.frequencia,
        tensaoRms: widget.resultado.tensaoFonte.magnitude,
        anguloFonteGraus: widget.resultado.tensaoFonte.angleDeg,
        blocos: widget.blocos,
      );
      final bytes = Uint8List.fromList(jsonStr.codeUnits);
      final nomeArquivo = '${widget.nomeCircuito.replaceAll(' ', '_')}.json';

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: nomeArquivo, mimeType: 'application/json')],
        text: 'Dados do circuito ${widget.nomeCircuito}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nao foi possivel exportar os dados: $e')),
        );
      }
    }
  }

  Widget _tituloSecao(String texto, IconData icone, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: cor.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C2541))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tensoesPorBloco = _tensoesPorBloco;
    final correntesPorBloco = _correntesPorBloco;
    final resultado = widget.resultado;
    final blocos = widget.blocos;

    final List<ElementoCircuito> todosElementos = [];
    final List<Complex> todasTensoes = [];
    final List<Complex> todasCorrentes = [];
    for (var b = 0; b < blocos.length; b++) {
      for (var i = 0; i < blocos[b].elementos.length; i++) {
        todosElementos.add(blocos[b].elementos[i]);
        todasTensoes.add(tensoesPorBloco[b][i]);
        todasCorrentes.add(correntesPorBloco[b][i]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(widget.nomeCircuito),
        backgroundColor: const Color(0xFF1C2541),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Exportar em PDF',
            icon: _exportando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.picture_as_pdf),
            onPressed: _exportando ? null : _exportarPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1C2541), Color(0xFF3A6FF7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.frequencia.toStringAsFixed(0)} Hz   |   ${blocos.length} bloco(s) em serie',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _MiniIndicador(rotulo: 'Zeq', valor: resultado.zEquivalente.toPolarString())),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Expanded(child: _MiniIndicador(rotulo: 'Corrente', valor: '${resultado.correnteTotal.toPolarString()} A')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconeComportamento, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${resultado.comportamento.toUpperCase()}   •   FP ${resultado.fatorDePotencia.toStringAsFixed(3)}   •   ${resultado.anguloDefasagem.toStringAsFixed(1)}°',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _tituloSecao('Esquematico', Icons.electrical_services, const Color(0xFF3A6FF7)),
            const Text('Toque com dois dedos para dar zoom nos graficos.', style: TextStyle(fontSize: 12, color: Colors.black38)),
            const SizedBox(height: 8),
            _CartaoBranco(
              child: RepaintBoundary(
                key: _keyEsquematico,
                child: EsquematicoWidget(
                  blocos: blocos,
                  tensaoRms: resultado.tensaoFonte.magnitude,
                  anguloFonteGraus: resultado.tensaoFonte.angleDeg,
                ),
              ),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Resultados gerais', Icons.insights, const Color(0xFF17B8A6)),
            _CardResultado(
              icone: Icons.bolt,
              titulo: 'Impedancia equivalente (Zeq)',
              valorRetangular: resultado.zEquivalente.toString(),
              valorPolar: resultado.zEquivalente.toPolarString(),
              cor: const Color(0xFF3A6FF7),
            ),
            _CardResultado(
              icone: Icons.flash_on,
              titulo: 'Corrente total (I)',
              valorRetangular: '${resultado.correnteTotal} A',
              valorPolar: '${resultado.correnteTotal.toPolarString()} A',
              cor: const Color(0xFF17B8A6),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Triangulo de potencias', Icons.change_history, const Color(0xFFFF8A3D)),
            _CartaoBranco(
              child: RepaintBoundary(
                key: _keyTriangulo,
                child: TrianguloPotenciasWidget(
                  p: resultado.potenciaAtiva,
                  q: resultado.potenciaReativa,
                  s: resultado.potenciaAparente,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _CartaoBranco(
              child: Column(
                children: [
                  _LinhaPotencia(label: 'Potencia ativa (P)', valor: '${resultado.potenciaAtiva.toStringAsFixed(2)} W', cor: const Color(0xFFFF8A3D)),
                  _LinhaPotencia(label: 'Potencia reativa (Q)', valor: '${resultado.potenciaReativa.toStringAsFixed(2)} var', cor: const Color(0xFFFF8A3D)),
                  _LinhaPotencia(label: 'Potencia aparente (S)', valor: '${resultado.potenciaAparente.toStringAsFixed(2)} VA', cor: const Color(0xFFFF8A3D)),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Diagrama fasorial geral', Icons.radar, const Color(0xFFB166E0)),
            _CartaoBranco(
              child: RepaintBoundary(
                key: _keyFasorialGeral,
                child: DiagramaFasorialWidget(
                  fasores: [
                    FasorItem(rotulo: 'V', valor: resultado.tensaoFonte, cor: const Color(0xFF3A6FF7)),
                    FasorItem(rotulo: 'I', valor: resultado.correnteTotal, cor: const Color(0xFF17B8A6)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Diagrama fasorial das tensoes', Icons.radar, const Color(0xFFB166E0)),
            _CartaoBranco(
              child: RepaintBoundary(
                key: _keyFasorialTensoes,
                child: DiagramaFasorialWidget(
                  unidade: 'V',
                  fasores: List.generate(
                    todosElementos.length,
                    (i) => FasorItem(rotulo: todosElementos[i].nome, valor: todasTensoes[i], cor: _paletaCores[i % _paletaCores.length]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Diagrama fasorial das correntes', Icons.radar, const Color(0xFFB166E0)),
            _CartaoBranco(
              child: RepaintBoundary(
                key: _keyFasorialCorrentes,
                child: DiagramaFasorialWidget(
                  unidade: 'A',
                  fasores: List.generate(
                    todosElementos.length,
                    (i) => FasorItem(rotulo: todosElementos[i].nome, valor: todasCorrentes[i], cor: _paletaCores[i % _paletaCores.length]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            _tituloSecao('Tensao e corrente em cada elemento', Icons.table_chart, const Color(0xFFE0566E)),
            ...List.generate(todosElementos.length, (i) {
              return _CardResultado(
                icone: Icons.memory,
                titulo: '${todosElementos[i].nome} (${todosElementos[i].nomeTipo})',
                valorRetangular: 'V: ${todasTensoes[i]} V   |   I: ${todasCorrentes[i]} A',
                valorPolar: 'V: ${todasTensoes[i].toPolarString()} V   |   I: ${todasCorrentes[i].toPolarString()} A',
                cor: _paletaCores[i % _paletaCores.length],
              );
            }),
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1C2541),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _exportando ? null : _exportarPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(_exportando ? 'Gerando PDF...' : 'Exportar relatorio em PDF'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _exportarDados,
              icon: const Icon(Icons.save_alt),
              label: const Text('Exportar dados do circuito (arquivo)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoBranco extends StatelessWidget {
  final Widget child;
  const _CartaoBranco({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _MiniIndicador extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _MiniIndicador({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CardResultado extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valorRetangular;
  final String valorPolar;
  final Color cor;

  const _CardResultado({
    required this.icone,
    required this.titulo,
    required this.valorRetangular,
    required this.valorPolar,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: cor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: TextStyle(fontWeight: FontWeight.w700, color: cor))),
            ],
          ),
          const SizedBox(height: 8),
          Text('Retangular: $valorRetangular', style: const TextStyle(fontSize: 14, color: Color(0xFF1C2541))),
          const SizedBox(height: 2),
          Text('Polar: $valorPolar', style: const TextStyle(fontSize: 14, color: Color(0xFF1C2541))),
        ],
      ),
    );
  }
}

class _LinhaPotencia extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _LinhaPotencia({required this.label, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF4F5D75)))),
          Text(valor, style: TextStyle(fontWeight: FontWeight.w700, color: cor)),
        ],
      ),
    );
  }
}