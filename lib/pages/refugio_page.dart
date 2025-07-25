import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class RefugioPage extends StatefulWidget {
  const RefugioPage({super.key});

  @override
  State<RefugioPage> createState() => _RefugioPageState();
}

class _RefugioPageState extends State<RefugioPage> {
  Map<String, dynamic>? refugio;
  List<dynamic> mascotas = [];
  List<dynamic> solicitudes = [];
  String mensaje = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final authResponse = await DioClient.dio.get('/refugios/api/auth/check');
      final authData = authResponse.data;

      if (authData['isValid'] == true && authData['tipo'] == 'refugio') {
        final perfilResponse = await DioClient.dio.get('/refugios/api/perfil');
        if (!mounted) return;
        setState(() {
          refugio = perfilResponse.data['refugio'];
        });
        await cargarMascotas();
        await cargarSolicitudes();
      } else {
        if (!mounted) return;
        Future.microtask(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar datos: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarMascotas() async {
    try {
      final response = await DioClient.dio.get('/refugios/mascotas');
      if (response.data['success'] == true && mounted) {
        setState(() {
          mascotas = response.data['mascotas'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar mascotas: $e';
      });
    }
  }

  Future<void> cargarSolicitudes() async {
    try {
      final response = await DioClient.dio.get(
        '/solicitudes/solicitudes',
        queryParameters: {'tipo': 'refugio', 'id': refugio?['idcentro']},
      );
      if (response.data['success'] == true && mounted) {
        setState(() {
          solicitudes = response.data['solicitudes'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar solicitudes: $e';
      });
    }
  }

 Future<void> actualizarEstadoSolicitud(int solicitudId, String nuevoEstado) async {
  try {
    final url = '/solicitudes/$solicitudId/estado';  // <-- Correcto si corriges el backend
    print('Enviando POST a: $url');

    final response = await DioClient.dio.post(
      url,
      data: {'estado': nuevoEstado},
    );

    if (response.data['success'] == true && mounted) {
      await cargarSolicitudes();
    } else {
      setState(() {
        mensaje = response.data['message'] ?? 'No se pudo actualizar el estado.';
      });
    }
  } catch (e) {
    setState(() {
      mensaje = 'Error al actualizar estado: $e';
    });
  }
}

  Future<void> logout() async {
    try {
      final response = await DioClient.dio.post('/refugios/logout');
      if (response.data['success'] == true && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cerrar sesión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Refugio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: refugio == null
          ? Center(child: Text(mensaje))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del Refugio',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Centro: ${refugio!['nombrecentro']}'),
                  Text('Encargado: ${refugio!['nombreencargado']}'),
                  Text('Correo: ${refugio!['correo']}'),
                  Text('Teléfono: ${refugio!['telefono']}'),
                  Text('Redes Sociales: ${refugio!['redesociales']}'),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mascotas Registradas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Future.microtask(() {
                            if (mounted) {
                              Navigator.pushNamed(context, '/registrarmascota');
                            }
                          });
                        },
                        child: const Text('Agregar Mascota'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (mascotas.isEmpty)
                    const Text('No hay mascotas registradas.')
                  else
                    ...mascotas.map((m) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        m['foto'] != null && m['foto'].toString().isNotEmpty
                                            ? 'https://moviltika-production.up.railway.app/uploads/${m['foto']}'
                                            : 'https://via.placeholder.com/80',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m['nombre'],
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text('${m['especie']} - ${m['genero']}'),
                                          Text('${m['edad']} años'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/mascotainfo', arguments: m);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                    ),
                                    child: const Text('Mostrar Mascota'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 30),

                  const Text(
                    'Solicitudes de Adopción',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (solicitudes.isEmpty)
                    const Text('No hay solicitudes.')
                  else
                    ...solicitudes.map((s) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mascota: ${s['mascota_nombre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Estado: ${s['estado']}'),
                                Text('Fecha: ${s['fecha']?.substring(0, 10) ?? 'N/A'}'),
                                const SizedBox(height: 8),
                                if (s['estado'] == 'pendiente')
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => actualizarEstadoSolicitud(s['idsolicitud'], 'aceptado'),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Aceptar'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () => actualizarEstadoSolicitud(s['idsolicitud'], 'rechazado'),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Rechazar'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 20),
                  if (mensaje.isNotEmpty)
                    Text(
                      mensaje,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/about'),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
