import 'package:flutter/material.dart';
import 'entrada_dados_tela.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuitos em CA'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Monte, calcule e analise seus circuitos em corrente alternada.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _CardAtalho(
              icone: Icons.add_circle_outline,
              titulo: 'Novo Circuito',
              subtitulo: 'Criar e calcular um novo circuito',
              cor: Colors.indigo,
              aoTocar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntradaDadosScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Circuitos recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: Center(
                child: Text(
                  'Nenhum circuito salvo ainda.',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAtalho extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback aoTocar;

  const _CardAtalho({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cor.withOpacity(0.15),
                child: Icon(icone, color: cor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}