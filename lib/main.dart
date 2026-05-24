import 'package:flutter/material.dart';

import 'ui/home_page.dart';

void main() {
  runApp(const WaterAnalyzerApp());
}

class WaterAnalyzerApp extends StatelessWidget {
  const WaterAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      ),
      home: const HomePage(),
    );
  }
}
