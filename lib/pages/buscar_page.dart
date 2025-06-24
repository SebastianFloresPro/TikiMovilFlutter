import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _busquedaController = TextEditingController();
  List<dynamic> resultados = [];
  bool cargando = false;
  String? error;

  Future<void> _buscar() async {
    final termino = _busquedaController.text.trim();
    if (termino.isEmpty) {
      setState(() {
        error = 'Debe escribir un término para buscar.';
        resultados = [];
      });
      return;
    }

    setState(() {
      cargando = true;
      resultados = [];
      error = null;
    });

    try {
      final response = await DioClient.dio.get(
        '/busqueda/mascotas/${Uri.encodeComponent(termino)}',
      );

      final data = response.data;
      print('📥 Backend respondió: $data');

      if (data['success'] == true && data['mascotas'] != null) {
        setState(() {
          resultados = data['mascotas'];
          if (resultados.isEmpty) {
            error = 'No se encontraron mascotas con ese término.';
          }
        });
      } else {
        setState(() {
          error = data['message'] ?? 'No se encontraron resultados.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error buscando mascotas. Revisa tu conexión.';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void _abrirDetalle(Map<String, dynamic> mascota) {
    Navigator.pushNamed(context, '/mascotainfosolicitud', arguments: mascota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar en TikaPaw')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o especie...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (cargando)
              const CircularProgressIndicator()
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red))
            else if (resultados.isEmpty)
              const Text('No hay resultados.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final m = resultados[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://moviltika-production.up.railway.app/uploads/${m['foto']?.split('/').last ?? 'default.jpg'}',
                          ),
                        ),
                        title: Text(m['nombre']),
                        subtitle:
                            Text('${m['especie']} - ${m['nombrecentro']}'),
                        onTap: () => _abrirDetalle(m),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: TikiNavBar(selectedIndex: 3),
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
