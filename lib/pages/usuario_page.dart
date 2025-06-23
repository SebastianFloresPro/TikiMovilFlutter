import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart'; 

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  Map<String, dynamic>? usuario;
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
      final authResponse = await DioClient.dio.get('/usuarios/api/auth/check');
      final authData = authResponse.data;

      if (authData['isValid'] == true && authData['tipo'] == 'usuario') {
        setState(() {
          usuario = {
            'nombre': authData['username'],
            'edad': authData['edad'],
            'correo': authData['correo'],
            'telefono': authData['telefono'],
            'userId': authData['userId'],
          };
        });
        await cargarSolicitudes(authData['userId']);
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar los datos: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarSolicitudes(int userId) async {
    try {
      final response = await DioClient.dio.get(
        '/solicitudes/solicitudes',
        queryParameters: {'tipo': 'usuario', 'id': userId},
      );

      final data = response.data;

      if (data['success'] == true && data['solicitudes'] != null) {
        setState(() {
          solicitudes = data['solicitudes'];
        });
      } else {
        setState(() {
          mensaje = 'No hay solicitudes.';
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
      final response = await DioClient.dio.post('/usuarios/logout');
      final data = response.data;

      if (data['success'] == true) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          mensaje = 'Error al cerrar sesión.';
        });
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
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: usuario == null
          ? Center(child: Text(mensaje))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos Personales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Nombre: ${usuario!['nombre']}'),
                  Text('Edad: ${usuario!['edad']}'),
                  Text('Correo: ${usuario!['correo']}'),
                  Text('Teléfono: ${usuario!['telefono']}'),
                  const SizedBox(height: 30),
                  const Text(
                    'Solicitudes de Adopción',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (solicitudes.isEmpty)
                    const Text('No hay solicitudes.')
                  else
                    ...solicitudes.map((sol) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Image.network(
                              sol['mascota_foto'] ?? 'https://via.placeholder.com/50',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text('Mascota: ${sol['mascota_nombre'] ?? '-'}'),
                            subtitle: Text(
                              'Estado: ${sol['estado']}\n'
                              'Fecha: ${sol['fecha']?.substring(0, 10) ?? 'N/A'}',
                            ),
                          ),
                        )),
                  const SizedBox(height: 20),
                  Text(
                    mensaje,
                    style: const TextStyle(color: Colors.red),
                  ),
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
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
