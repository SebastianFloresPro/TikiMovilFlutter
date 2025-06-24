import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List<dynamic> mascotas = [];
  bool cargando = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final response = await DioClient.dio.get('/mascotas');
      final data = response.data;

      if (data['success'] == true && data['mascotas'] != null) {
        final lista = List.from(data['mascotas']);
        lista.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));
        setState(() {
          mascotas = lista.take(5).toList(); // solo los 5 primeros
        });
      } else {
        setState(() {
          error = data['message'] ?? 'No se encontraron mascotas.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al cargar las mascotas.';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void _verMascota(Map<String, dynamic> mascota) {
    Navigator.pushNamed(context, '/mascotainfosolicitud', arguments: mascota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TikaPaw')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cada patita tiene una historia esperando ser escrita. Dale una segunda oportunidad al amor, conoce a tu futura mascota.\nLa felicidad comienza con un ladrido, un ronroneo… ¿Estás listo para recibirla?',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¿Por qué adoptar en TikaPaw?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• Amor Incondicional: Encuentra un compañero fiel que llenará tu vida de alegría.\n'
                    '• Apoya a Refugios: Cada adopción contribuye a rescatar más animales necesitados.\n'
                    '• Un hogar para siempre: Brindas una segunda oportunidad a un ser lleno de amor.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Mascotas en adopción',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ...mascotas.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      'https://moviltika-production.up.railway.app/uploads/cat.jpeg', // Imagen fija
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                                        height: 200,
                                        child: Center(child: Text('Imagen no disponible')),
                                      ),
                                    ),
                                  ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['nombre'] ?? 'Sin nombre',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () => _verMascota(m),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                  child: const Text('Adóptame'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/refugios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Ver más mascotas'),
                    ),
                  ),
                ],
              ),
            ),

      // ✅ Protegemos el render del BottomAppBar con FutureBuilder
      bottomNavigationBar: FutureBuilder(
        future: Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const TikiNavBar(selectedIndex: 0);
          }
          return const SizedBox.shrink(); // mientras espera, no muestra nada
        },
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
