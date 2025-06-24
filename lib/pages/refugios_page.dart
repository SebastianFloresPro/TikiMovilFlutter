import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';
import 'refugioinformacion_page.dart';

class RefugiosPage extends StatefulWidget {
  const RefugiosPage({super.key});

  @override
  State<RefugiosPage> createState() => _RefugiosPageState();
}

class _RefugiosPageState extends State<RefugiosPage> {
  List<dynamic> refugios = [];
  bool cargando = true;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    cargarRefugios();
  }

  Future<void> cargarRefugios() async {
    try {
      final response = await DioClient.dio.get('/refugios/refugios');
      if (response.data['success'] == true && mounted) {
        setState(() {
          refugios = response.data['refugios'];
        });
      } else {
        setState(() {
          mensaje = 'No se pudieron cargar los refugios.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar refugios: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refugios'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : refugios.isEmpty
              ? Center(child: Text(mensaje.isNotEmpty ? mensaje : 'No hay refugios disponibles.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: refugios.length,
                  itemBuilder: (context, index) {
                    final refugio = refugios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(refugio['nombrecentro'] ?? 'Sin nombre'),
                        subtitle: Text('Encargado: ${refugio['nombreencargado'] ?? 'N/A'}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RefugioInformacionPage(refugio: refugio),
                              ),
                            );
                          },
                          child: const Text('Ver'),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: 1),
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
