import 'package:flutter/material.dart';
import '../calculation/bloco_circuito.dart';
import '../calculation/circuito.dart';
import '../calculation/complex.dart';
import '../calculation/elemento_circuito.dart';
import '../widgets/esquematico_widget.dart';
import 'resultado_tela.dart';

class EntradaDadosScreen extends StatefulWidget {
  const EntradaDadosScreen({super.key});

  @override
  State<EntradaDadosScreen> createState() => _EntradaDadosScreenState();
}

class _ElementoForm {
  TipoElemento tipo = TipoElemento.resistor;
  final TextEditingController valorController = TextEditingController();
}

class _BlocoForm {
  final List<_ElementoForm> elementos = [_ElementoForm()];
}

class _FonteForm {
  final TextEditingController magnitudeController;
  final TextEditingController anguloController;
  _FonteForm({String magnitude = '127', String angulo = '0'})
      : magnitudeController = TextEditingController(text: magnitude),
        anguloController = TextEditingController(text: angulo);
}

class _EntradaDadosScreenState extends State<EntradaDadosScreen> {
  final _nomeController = TextEditingController(text: 'Meu circuito');
  final _frequenciaController = TextEditingController(text: '60');

  final List<TextEditingController> _autoresControllers = [TextEditingController()];

  TipoFonte _tipoFonte = TipoFonte.tensao;

  final List<_FonteForm> _fontesTensao = [_FonteForm(magnitude: '127', angulo: '0')];
  final _fonteCorrente = _FonteForm(magnitude: '5', angulo: '0');

  final List<_BlocoForm> _blocos = [_BlocoForm()];

  void _adicionarAutor() {
    if (_autoresControllers.length >= 5) return;
    setState(() => _autoresControllers.add(TextEditingController()));
  }

  void _removerAutor(int index) {
    if (_autoresControllers.length <= 1) return;
    setState(() => _autoresControllers.removeAt(index));
  }

  void _adicionarFonteTensao() {
    if (_fontesTensao.length >= 10) return;
    setState(() => _fontesTensao.add(_FonteForm(magnitude: '127', angulo: '0')));
  }

  void _removerFonteTensao(int index) {
    if (_fontesTensao.length <= 1) return;
    setState(() => _fontesTensao.removeAt(index));
  }

  void _adicionarBloco() {
    if (_blocos.length >= 50) return;
    setState(() => _blocos.add(_BlocoForm()));
  }

  void _removerBloco(int index) {
    if (_blocos.length <= 1) return;
    setState(() => _blocos.removeAt(index));
  }

  void _adicionarElementoNoBloco(int blocoIndex) {
    final totalElementos = _blocos.fold<int>(0, (acc, b) => acc + b.elementos.length);
    if (totalElementos >= 50) return;
    setState(() => _blocos[blocoIndex].elementos.add(_ElementoForm()));
  }

  void _removerElementoDoBloco(int blocoIndex, int elementoIndex) {
    if (_blocos[blocoIndex].elementos.length <= 1) return;
    setState(() => _blocos[blocoIndex].elementos.removeAt(elementoIndex));
  }

  List<BlocoCircuito> _construirBlocos() {
    final List<BlocoCircuito> resultado = [];
    var contador = 1;
    for (final b in _blocos) {
      final elementos = <ElementoCircuito>[];
      for (final e in b.elementos) {
        final valor = double.tryParse(e.valorController.text.replaceAll(',', '.')) ?? 0.0;
        elementos.add(ElementoCircuito(nome: 'Z${contador++}', tipo: e.tipo, valorOhms: valor));
      }
      resultado.add(BlocoCircuito(elementos: elementos));
    }
    return resultado;
  }

  List<FonteEletrica> _construirFontes() {
    if (_tipoFonte == TipoFonte.tensao) {
      return _fontesTensao.map((f) {
        final mag = double.tryParse(f.magnitudeController.text.replaceAll(',', '.')) ?? 0.0;
        final ang = double.tryParse(f.anguloController.text.replaceAll(',', '.')) ?? 0.0;
        return FonteEletrica(magnitude: mag, anguloGraus: ang);
      }).toList();
    } else {
      final mag = double.tryParse(_fonteCorrente.magnitudeController.text.replaceAll(',', '.')) ?? 0.0;
      final ang = double.tryParse(_fonteCorrente.anguloController.text.replaceAll(',', '.')) ?? 0.0;
      return [FonteEletrica(magnitude: mag, anguloGraus: ang)];
    }
  }

  List<String> _construirAutores() {
    return _autoresControllers
        .map((c) => c.text.trim())
        .where((nome) => nome.isNotEmpty)
        .toList();
  }

  Complex _fonteEquivalentePreview() {
    final fontes = _construirFontes();
    if (_tipoFonte == TipoFonte.tensao) {
      var soma = const Complex(0, 0);
      for (final f in fontes) {
        soma = soma + Complex.fromPolar(f.magnitude, f.anguloGraus);
      }
      return soma;
    }
    return Complex.fromPolar(fontes.first.magnitude, fontes.first.anguloGraus);
  }

  void _calcular() {
    final frequencia = double.tryParse(_frequenciaController.text.replaceAll(',', '.')) ?? 60.0;

    final blocos = _construirBlocos();
    final fontes = _construirFontes();
    final autores = _construirAutores();

    final temElementoInvalido = blocos.any((b) => b.elementos.any((e) => e.valorOhms <= 0));
    if (temElementoInvalido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha um valor maior que zero para todos os elementos.')),
      );
      return;
    }

    final temFonteInvalida = fontes.any((f) => f.magnitude <= 0);
    if (temFonteInvalida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha um valor maior que zero para todas as fontes.')),
      );
      return;
    }

    final resultado = CircuitSolver.resolver(
      blocos: blocos,
      tipoFonte: _tipoFonte,
      fontes: fontes,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoScreen(
          nomeCircuito: _nomeController.text.isEmpty ? 'Circuito' : _nomeController.text,
          frequencia: frequencia,
          blocos: blocos,
          resultado: resultado,
          autores: autores,
        ),
      ),
    );
  }

  Widget _campoFonte(_FonteForm fonte, {required String rotuloModulo, VoidCallback? onRemover}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: fonte.magnitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: rotuloModulo, border: const OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: fonte.anguloController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Angulo (graus)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (onRemover != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
              onPressed: onRemover,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocosPreview = _construirBlocos();
    final fonteEquivalente = _fonteEquivalentePreview();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo circuito')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do circuito', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          const Text('Autores (opcional, ate 5)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          ...List.generate(_autoresControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _autoresControllers[i],
                      decoration: InputDecoration(labelText: 'Nome ${i + 1}', border: const OutlineInputBorder()),
                    ),
                  ),
                  if (_autoresControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                      onPressed: () => _removerAutor(i),
                    ),
                ],
              ),
            );
          }),
          if (_autoresControllers.length < 5)
            TextButton.icon(
              onPressed: _adicionarAutor,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar autor'),
            ),
          const SizedBox(height: 20),

          const Text('Tipo de fonte', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<TipoFonte>(
            segments: const [
              ButtonSegment(value: TipoFonte.tensao, label: Text('Fonte de tensao')),
              ButtonSegment(value: TipoFonte.corrente, label: Text('Fonte de corrente')),
            ],
            selected: {_tipoFonte},
            onSelectionChanged: (novo) => setState(() => _tipoFonte = novo.first),
          ),
          const SizedBox(height: 12),
          if (_tipoFonte == TipoFonte.tensao) ...[
            const Text(
              'Independentes, em serie: os valores digitados abaixo se somam para formar a fonte final.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            ...List.generate(_fontesTensao.length, (i) {
              return _campoFonte(
                _fontesTensao[i],
                rotuloModulo: 'Fonte ${i + 1} - Tensao RMS (V)',
                onRemover: _fontesTensao.length > 1 ? () => _removerFonteTensao(i) : null,
              );
            }),
            TextButton.icon(
              onPressed: _adicionarFonteTensao,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar fonte de tensao em serie'),
            ),
          ] else ...[
            const Text(
              'Independente: numa malha em serie so pode existir uma fonte de corrente guiando o circuito.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            _campoFonte(_fonteCorrente, rotuloModulo: 'Corrente RMS (A)'),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _frequenciaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Frequencia (Hz)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text(
            'Monte o circuito livremente: cada bloco abaixo fica em SERIE com os demais. '
            'Se voce colocar mais de um elemento dentro do mesmo bloco, eles ficam em PARALELO entre si.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...List.generate(_blocos.length, (blocoIndex) {
            final bloco = _blocos[blocoIndex];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bloco ${blocoIndex + 1}'
                            '${bloco.elementos.length > 1 ? ' (paralelo interno)' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        if (_blocos.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removerBloco(blocoIndex),
                          ),
                      ],
                    ),
                    ...List.generate(bloco.elementos.length, (elIndex) {
                      final el = bloco.elementos[elIndex];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SegmentedButton<TipoElemento>(
                                segments: const [
                                  ButtonSegment(value: TipoElemento.resistor, label: Text('R (0°)')),
                                  ButtonSegment(value: TipoElemento.indutor, label: Text('L (90°)')),
                                  ButtonSegment(value: TipoElemento.capacitor, label: Text('C (-90°)')),
                                ],
                                selected: {el.tipo},
                                onSelectionChanged: (novo) => setState(() => el.tipo = novo.first),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: el.valorController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Valor (ohms)', border: OutlineInputBorder()),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (bloco.elementos.length > 1)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                onPressed: () => _removerElementoDoBloco(blocoIndex, elIndex),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _adicionarElementoNoBloco(blocoIndex),
                      icon: const Icon(Icons.call_split),
                      label: const Text('Adicionar elemento em paralelo neste bloco'),
                    ),
                  ],
                ),
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _adicionarBloco,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar bloco em serie'),
          ),
          const SizedBox(height: 24),
          const Text('Pre-visualizacao do esquematico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          EsquematicoWidget(
            blocos: blocosPreview,
            tensaoRms: fonteEquivalente.magnitude,
            anguloFonteGraus: fonteEquivalente.angleDeg,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _calcular,
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular'),
          ),
        ],
      ),
    );
  }
}