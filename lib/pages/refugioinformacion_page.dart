import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class RefugioInformacionPage extends StatefulWidget {
  final Map<String, dynamic> refugio;

  const RefugioInformacionPage({super.key, required this.refugio});

  @override
  State<RefugioInformacionPage> createState() => _RefugioInformacionPageState();
}

class _RefugioInformacionPageState extends State<RefugioInformacionPage> {
  List<dynamic> mascotas = [];
  bool cargando = true;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    cargarMascotas();
  }

  Future<void> cargarMascotas() async {
    try {
      final response = await DioClient.dio.get('/refugios/mascotas/${widget.refugio['idcentro']}');
      if (response.data['success'] == true) {
        setState(() {
          mascotas = response.data['mascotas'];
          cargando = false;
        });
      } else {
        setState(() {
          mensaje = 'No se pudieron cargar las mascotas';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar mascotas: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final refugio = widget.refugio;

    return Scaffold(
      appBar: AppBar(
        title: Text('Refugio: ${refugio['nombrecentro']}'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Encargado: ${refugio['nombreencargado']}', style: const TextStyle(fontSize: 18)),
                Text('Correo: ${refugio['correo']}', style: const TextStyle(fontSize: 16)),
                Text('Teléfono: ${refugio['telefono']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const Text('Mascotas en este refugio:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (mensaje.isNotEmpty)
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                ...mascotas.map((m) => Card(
                      child: ListTile(
                        leading: m['foto'] != null
                            ? Image.network(
                                'https://moviltika-production.up.railway.app/uploads/${m['foto']}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.pets),
                        title: Text(m['nombre'] ?? '-'),
                        subtitle: Text('${m['especie']} - ${m['edad']} años'),
                        onTap: () => Navigator.pushNamed(
                            context,
                            '/mascotainfosolicitud',
                            arguments: m,
                          ),
                      ),
                    )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver a Refugios'),
                )
              ],
            ),
    );
  }
}
