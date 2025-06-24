import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../helpers/dio_client.dart';

class MascotaInfoPage extends StatefulWidget {
  final Map<String, dynamic> mascota;

  const MascotaInfoPage({super.key, required this.mascota});

  @override
  State<MascotaInfoPage> createState() => _MascotaInfoPageState();
}

class _MascotaInfoPageState extends State<MascotaInfoPage> {
  List<dynamic> solicitudes = [];
  String mensaje = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    try {
      final response = await DioClient.dio.get(
        '/solicitudes/mascota/${widget.mascota['idmascota']}',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      if (!mounted) return;

      if (response.statusCode == 404) {
        setState(() {
          solicitudes = [];
        });
      } else if (response.data['success'] == true) {
        setState(() {
          solicitudes = response.data['solicitudes'];
        });
      } else {
        setState(() {
          mensaje = response.data['message'] ?? 'Error desconocido';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar solicitudes: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mascota;

    return Scaffold(
      appBar: AppBar(title: Text('Información de ${m['nombre']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  m['foto'] != null && m['foto'].toString().isNotEmpty
                      ? 'https://moviltika-production.up.railway.app/uploads/${m['foto']}'
                      : 'https://via.placeholder.com/200',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Nombre: ${m['nombre']}', style: const TextStyle(fontSize: 18)),
            Text('Edad: ${m['edad']} años', style: const TextStyle(fontSize: 18)),
            Text('Especie: ${m['especie']}', style: const TextStyle(fontSize: 18)),
            Text('Género: ${m['genero']}', style: const TextStyle(fontSize: 18)),
            Text('Tamaño: ${m['tamanio']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(m['descripcion'] ?? '-', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            const Text('Solicitudes para esta mascota:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (cargando)
              const CircularProgressIndicator()
            else if (solicitudes.isEmpty)
              const Text('No hay solicitudes registradas.')
            else
              ...solicitudes.map((s) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text('Estado: ${s['estado']}'),
                      subtitle: Text('Fecha: ${s['fecha']?.substring(0, 10) ?? 'N/A'}'),
                    ),
                  )),
            const SizedBox(height: 20),

            if (mensaje.isNotEmpty)
              Text(mensaje, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/refugio');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Volver al perfil del refugio'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
