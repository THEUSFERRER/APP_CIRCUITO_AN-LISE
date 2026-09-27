import 'package:flutter/material.dart';
import '../calculation/complex.dart';
import '../calculation/circuito.dart';
import '../calculation/impedancia.dart';
import '../calculation/elemento_circuito.dart';
import '../widgets/esquematico_widget.dart';
import '../widgets/fasor_widget.dart';
import '../widgets/triangulo_potencias_widget.dart';
import 'entrada_dados_tela.dart';

class ResultadoScreen extends StatelessWidget {
  final String nomeCircuito;
  final double frequencia;
  final TipoConexao tipoConexao;
  final List<ElementoCircuito> elementos;
  final CircuitResult resultado;

  const ResultadoScreen({
    super.key,
    required this.nomeCircuito,
    required this.frequencia,
    required this.tipoConexao,
    required this.elementos,
    required this.resultado,
  });

  String get _nomeTipoConexao {
    switch (tipoConexao) {
      case TipoConexao.serie:
        return 'Serie';
      case TipoConexao.paralelo:
        return 'Paralelo';
      case TipoConexao.misto:
        return 'Misto (Z1 serie com Z2 paralelo Z3)';
    }
  }

  Color get _corComportamento {
    switch (resultado.comportamento) {
      case 'indutivo':
        return Colors.orange;
      case 'capacitivo':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  List<Complex> get _tensoesElementos {
    switch (tipoConexao) {
      case TipoConexao.serie:
        return elementos.map((e) => CircuitSolver.tensaoNoElemento(resultado.correnteTotal, e.impedancia)).toList();
      case TipoConexao.paralelo:
        return elementos.map((_) => resultado.tensaoFonte).toList();
      case TipoConexao.misto:
        if (elementos.length < 3) {
          return elementos.map((e) => CircuitSolver.tensaoNoElemento(resultado.correnteTotal, e.impedancia)).toList();
        }
        final tensaoZ1 = CircuitSolver.tensaoNoElemento(resultado.correnteTotal, elementos[0].impedancia);
        final zParalelo = ImpedanceCalculator.paralelo([elementos[1].impedancia, elementos[2].impedancia]);
        final tensaoParalelo = resultado.correnteTotal * zParalelo;
        return [tensaoZ1, tensaoParalelo, tensaoParalelo];
    }
  }

  List<Complex> get _correntesElementos {
    final tensoes = _tensoesElementos;
    switch (tipoConexao) {
      case TipoConexao.serie:
        return List.filled(elementos.length, resultado.correnteTotal);
      case TipoConexao.paralelo:
        return List.generate(elementos.length, (i) => tensoes[i] / elementos[i].impedancia);
      case TipoConexao.misto:
        if (elementos.length < 3) {
          return List.filled(elementos.length, resultado.correnteTotal);
        }
        final correnteZ2 = tensoes[1] / elementos[1].impedancia;
        final correnteZ3 = tensoes[2] / elementos[2].impedancia;
        return [resultado.correnteTotal, correnteZ2, correnteZ3];
    }
  }

  static const List<Color> _paletaCores = [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.purple];

  @override
  Widget build(BuildContext context) {
    final tensoes = _tensoesElementos;
    final correntes = _correntesElementos;

    return Scaffold(
      appBar: AppBar(title: Text(nomeCircuito)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Conexao: $_nomeTipoConexao   |   Frequencia: ${frequencia.toStringAsFixed(0)} Hz',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          const Text('Toque com dois dedos para dar zoom nos graficos.', style: TextStyle(fontSize: 12, color: Colors.black38)),
          const SizedBox(height: 12),
          const Text('Esquematico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          EsquematicoWidget(elementos: elementos, tipoConexao: tipoConexao),
          const SizedBox(height: 20),
          _CardResultado(
            titulo: 'Impedancia equivalente (Zeq)',
            valorRetangular: resultado.zEquivalente.toString(),
            valorPolar: resultado.zEquivalente.toPolarString(),
            cor: Colors.indigo,
          ),
          _CardResultado(
            titulo: 'Corrente total (I)',
            valorRetangular: '${resultado.correnteTotal} A',
            valorPolar: '${resultado.correnteTotal.toPolarString()} A',
            cor: Colors.teal,
          ),
          const SizedBox(height: 8),
          Card(
            color: _corComportamento.withOpacity(0.12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: _corComportamento),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Comportamento ${resultado.comportamento.toUpperCase()}   |   '
                      'Fator de potencia: ${resultado.fatorDePotencia.toStringAsFixed(3)}   |   '
                      'Defasagem: ${resultado.anguloDefasagem.toStringAsFixed(2)} graus',
                      style: TextStyle(color: _corComportamento, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Triangulo de potencias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TrianguloPotenciasWidget(
            p: resultado.potenciaAtiva,
            q: resultado.potenciaReativa,
            s: resultado.potenciaAparente,
          ),
          const SizedBox(height: 8),
          _LinhaPotencia(label: 'Potencia ativa (P)', valor: '${resultado.potenciaAtiva.toStringAsFixed(2)} W'),
          _LinhaPotencia(label: 'Potencia reativa (Q)', valor: '${resultado.potenciaReativa.toStringAsFixed(2)} var'),
          _LinhaPotencia(label: 'Potencia aparente (S)', valor: '${resultado.potenciaAparente.toStringAsFixed(2)} VA'),
          const SizedBox(height: 20),
          const Text('Diagrama fasorial geral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DiagramaFasorialWidget(
            fasores: [
              FasorItem(rotulo: 'V', valor: resultado.tensaoFonte, cor: Colors.indigo),
              FasorItem(rotulo: 'I', valor: resultado.correnteTotal, cor: Colors.teal),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Diagrama fasorial das tensoes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DiagramaFasorialWidget(
            unidade: 'V',
            fasores: List.generate(
              elementos.length,
              (i) => FasorItem(rotulo: elementos[i].nome, valor: tensoes[i], cor: _paletaCores[i % _paletaCores.length]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Diagrama fasorial das correntes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DiagramaFasorialWidget(
            unidade: 'A',
            fasores: List.generate(
              elementos.length,
              (i) => FasorItem(rotulo: elementos[i].nome, valor: correntes[i], cor: _paletaCores[i % _paletaCores.length]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Tensao em cada elemento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...List.generate(elementos.length, (i) {
            return _CardResultado(
              titulo: '${elementos[i].nome} (${elementos[i].nomeTipo})',
              valorRetangular: '${tensoes[i]} V',
              valorPolar: '${tensoes[i].toPolarString()} V',
              cor: Colors.deepPurple,
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('Voltar ao inicio'),
          ),
        ],
      ),
    );
  }
}

class _CardResultado extends StatelessWidget {
  final String titulo;
  final String valorRetangular;
  final String valorPolar;
  final Color cor;

  const _CardResultado({
    required this.titulo,
    required this.valorRetangular,
    required this.valorPolar,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, color: cor)),
            const SizedBox(height: 6),
            Text('Retangular: $valorRetangular', style: const TextStyle(fontSize: 15)),
            Text('Polar: $valorPolar', style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _LinhaPotencia extends StatelessWidget {
  final String label;
  final String valor;

  const _LinhaPotencia({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}