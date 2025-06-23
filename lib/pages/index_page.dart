import 'package:flutter/material.dart';
import '../widgets/tiki_navbar.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Inicio - TikaPaw'),
      ),
      body: const Center(
        child: Text('Bienvenido a TikaPaw', style: TextStyle(fontSize: 18)),
      ),
      bottomNavigationBar: TikiNavBar(
        selectedIndex: 0, // Índice para "home"
        context: context,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/about'),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
