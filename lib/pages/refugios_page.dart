import 'package:flutter/material.dart';
import '../widgets/tiki_navbar.dart';

class RefugiosPage extends StatelessWidget {
  const RefugiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refugios'),
      ),
      body: const Center(
        child: Text(
          'Aquí irán los refugios disponibles',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: TikiNavBar(
        selectedIndex: 1, // Refugios
        context: context,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/about');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
