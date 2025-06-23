import 'package:flutter/material.dart';
import '../widgets/tiki_navbar.dart'; // Asegúrate de tener este import

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _busquedaController = TextEditingController();
  String _resultado = '';

  void _buscar() {
    setState(() {
      _resultado = _busquedaController.text.trim().isEmpty
          ? 'Escribe algo para buscar.'
          : 'No se encontraron resultados para: "${_busquedaController.text}"';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar en TikaPaw')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar refugio o mascota...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _resultado,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TikiNavBar(
        selectedIndex: 3, // Buscar
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
