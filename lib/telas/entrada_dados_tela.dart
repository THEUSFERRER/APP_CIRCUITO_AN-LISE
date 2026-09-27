import 'package:flutter/material.dart';
import '../calculation/complex.dart';
import '../calculation/impedancia.dart';
import '../calculation/circuito.dart';
import '../calculation/elemento_circuito.dart';
import '../widgets/esquematico_widget.dart';
import 'resultado_tela.dart';

enum TipoConexao { serie, paralelo, misto }

class EntradaDadosScreen extends StatefulWidget {
  const EntradaDadosScreen({super.key});

  @override
  State<EntradaDadosScreen> createState() => _EntradaDadosScreenState();
}

class _ItemElemento {
  TipoElemento tipo = TipoElemento.resistor;
  final TextEditingController valorController = TextEditingController(text: '10');
}

class _EntradaDadosScreenState extends State<EntradaDadosScreen> {
  final _nomeController = TextEditingController(text: 'Circuito 1');
  final _tensaoController = TextEditingController(text: '220');
  final _anguloController = TextEditingController(text: '0');
  final _frequenciaController = TextEditingController(text: '60');

  TipoConexao _tipoConexao = TipoConexao.serie;

  final List<_ItemElemento> _itens = [_ItemElemento(), _ItemElemento()];
  final List<String> _nomesImpedancias = ['Z1', 'Z2'];

  void _adicionarElemento() {
    if (_itens.length >= 3) return;
    setState(() {
      _nomesImpedancias.add('Z${_itens.length + 1}');
      _itens.add(_ItemElemento());
    });
  }

  void _removerElemento(int index) {
    if (_itens.length <= 1) return;
    setState(() {
      _itens.removeAt(index);
      _nomesImpedancias.removeAt(index);
    });
  }

  ElementoCircuito _construirElemento(int i) {
    final item = _itens[i];
    final v = double.tryParse(item.valorController.text) ?? 0;
    return ElementoCircuito(nome: _nomesImpedancias[i], tipo: item.tipo, valorOhms: v);
  }

  void _calcular() {
    final tensaoMag = double.tryParse(_tensaoController.text) ?? 0;
    final anguloFonte = double.tryParse(_anguloController.text) ?? 0;
    final frequencia = double.tryParse(_frequenciaController.text) ?? 60;

    final tensaoFonte = Complex.fromPolar(tensaoMag, anguloFonte);

    final elementos = List.generate(_itens.length, _construirElemento);
    final impedancias = elementos.map((e) => e.impedancia).toList();

    Complex zEquivalente;
    switch (_tipoConexao) {
      case TipoConexao.serie:
        zEquivalente = ImpedanceCalculator.serie(impedancias);
        break;
      case TipoConexao.paralelo:
        zEquivalente = ImpedanceCalculator.paralelo(impedancias);
        break;
      case TipoConexao.misto:
        if (impedancias.length < 3) {
          _mostrarErro('O modo misto precisa de Z1, Z2 e Z3.');
          return;
        }
        zEquivalente = ImpedanceCalculator.mistoZ1SerieZ2ParaleloZ3(
          impedancias[0],
          impedancias[1],
          impedancias[2],
        );
        break;
    }

    final resultado = CircuitSolver.resolver(
      tensaoFonte: tensaoFonte,
      zEquivalente: zEquivalente,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoScreen(
          nomeCircuito: _nomeController.text,
          frequencia: frequencia,
          tipoConexao: _tipoConexao,
          elementos: elementos,
          resultado: resultado,
        ),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Circuito')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do circuito', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tensaoController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Tensao RMS (V)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _anguloController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Angulo da fonte (graus)', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _frequenciaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Frequencia (Hz)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text('Tipo de conexao', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<TipoConexao>(
            segments: const [
              ButtonSegment(value: TipoConexao.serie, label: Text('Serie')),
              ButtonSegment(value: TipoConexao.paralelo, label: Text('Paralelo')),
              ButtonSegment(value: TipoConexao.misto, label: Text('Misto')),
            ],
            selected: {_tipoConexao},
            onSelectionChanged: (novo) {
              setState(() => _tipoConexao = novo.first);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Elementos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              TextButton.icon(
                onPressed: _adicionarElemento,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          ...List.generate(_itens.length, (i) {
            final item = _itens[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_nomesImpedancias[i], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          onPressed: () => _removerElemento(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    SegmentedButton<TipoElemento>(
                      segments: const [
                        ButtonSegment(value: TipoElemento.resistor, label: Text('Resistor (0°)')),
                        ButtonSegment(value: TipoElemento.indutor, label: Text('Indutor (90°)')),
                        ButtonSegment(value: TipoElemento.capacitor, label: Text('Capacitor (-90°)')),
                      ],
                      selected: {item.tipo},
                      onSelectionChanged: (novo) {
                        setState(() => item.tipo = novo.first);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: item.valorController,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'Valor (ohms)', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text('Pre-visualizacao do esquematico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          EsquematicoWidget(
            elementos: List.generate(_itens.length, _construirElemento),
            tipoConexao: _tipoConexao,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _calcular,
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }
}