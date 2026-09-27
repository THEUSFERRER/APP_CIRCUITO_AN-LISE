import 'package:flutter/material.dart';
import 'telas/dashboard_tela.dart';

void main() {
  runApp(const CircuitosApp());
}

class CircuitosApp extends StatelessWidget {
  const CircuitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuitos CA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const DashboardScreen(),
    );
  }
}