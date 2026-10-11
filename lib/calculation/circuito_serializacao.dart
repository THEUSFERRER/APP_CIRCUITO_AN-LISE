import 'dart:convert';
import 'elemento_circuito.dart';
import 'bloco_circuito.dart';

Map<String, dynamic> circuitoParaMapa({
  required String nomeCircuito,
  required double frequencia,
  required double tensaoRms,
  required double anguloFonteGraus,
  required List<BlocoCircuito> blocos,
}) {
  return {
    'nomeCircuito': nomeCircuito,
    'frequencia': frequencia,
    'tensaoRms': tensaoRms,
    'anguloFonteGraus': anguloFonteGraus,
    'blocos': blocos
        .map((b) => {
              'elementos': b.elementos
                  .map((e) => {
                        'nome': e.nome,
                        'tipo': e.tipo.name,
                        'valorOhms': e.valorOhms,
                      })
                  .toList(),
            })
        .toList(),
  };
}

String circuitoParaJson({
  required String nomeCircuito,
  required double frequencia,
  required double tensaoRms,
  required double anguloFonteGraus,
  required List<BlocoCircuito> blocos,
}) {
  final mapa = circuitoParaMapa(
    nomeCircuito: nomeCircuito,
    frequencia: frequencia,
    tensaoRms: tensaoRms,
    anguloFonteGraus: anguloFonteGraus,
    blocos: blocos,
  );
  return const JsonEncoder.withIndent('  ').convert(mapa);
}

class CircuitoImportado {
  final String nomeCircuito;
  final double frequencia;
  final double tensaoRms;
  final double anguloFonteGraus;
  final List<BlocoCircuito> blocos;

  CircuitoImportado({
    required this.nomeCircuito,
    required this.frequencia,
    required this.tensaoRms,
    required this.anguloFonteGraus,
    required this.blocos,
  });

  factory CircuitoImportado.fromJson(String jsonStr) {
    final mapa = json.decode(jsonStr) as Map<String, dynamic>;
    final blocos = (mapa['blocos'] as List).map((b) {
      final elementos = (b['elementos'] as List).map((e) {
        return ElementoCircuito(
          nome: e['nome'] as String,
          tipo: TipoElemento.values.firstWhere((t) => t.name == e['tipo']),
          valorOhms: (e['valorOhms'] as num).toDouble(),
        );
      }).toList();
      return BlocoCircuito(elementos: elementos);
    }).toList();

    return CircuitoImportado(
      nomeCircuito: mapa['nomeCircuito'] as String,
      frequencia: (mapa['frequencia'] as num).toDouble(),
      tensaoRms: (mapa['tensaoRms'] as num).toDouble(),
      anguloFonteGraus: (mapa['anguloFonteGraus'] as num).toDouble(),
      blocos: blocos,
    );
  }
}