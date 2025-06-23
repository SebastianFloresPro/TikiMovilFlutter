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
        setState(() {
          refugio = perfilResponse.data['refugio'];
        });
        await cargarMascotas();
        await cargarSolicitudes();
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarMascotas() async {
    try {
      final response = await DioClient.dio.get('/refugios/mascotas');
      if (response.data['success'] == true) {
        setState(() {
          mascotas = response.data['mascotas'];
        });
      }
    } catch (e) {
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
      if (response.data['success'] == true) {
        setState(() {
          solicitudes = response.data['solicitudes'];
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar solicitudes: $e';
      });
    }
  }

  Future<void> logout() async {
    try {
      final response = await DioClient.dio.post('/refugios/logout');
      if (response.data['success'] == true) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
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
                  const Text('Datos del Refugio',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      const Text('Mascotas Registradas',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registrarmascota');
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
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                m['foto'] ?? 'https://via.placeholder.com/50',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(m['nombre']),
                            subtitle: Text('${m['especie']} - ${m['genero']}, ${m['edad']} años'),
                          ),
                        )),
                  const SizedBox(height: 30),

                  const Text('Solicitudes de Adopción',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (solicitudes.isEmpty)
                    const Text('No hay solicitudes.')
                  else
                    ...solicitudes.map((s) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Mascota: ${s['mascota_nombre']}'),
                            subtitle: Text('Estado: ${s['estado']}, Fecha: ${s['fecha']?.substring(0, 10) ?? 'N/A'}'),
                          ),
                        )),
                  const SizedBox(height: 20),
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
      bottomNavigationBar: TikiNavBar(
        selectedIndex: 4,
        context: context,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/about');
        },
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
