import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import 'solicitudes_page.dart';

class MascotaInfoSolicitudPage extends StatelessWidget {
  final Map<String, dynamic> mascota;

  const MascotaInfoSolicitudPage({super.key, required this.mascota});

  Future<void> irAlFormulario(BuildContext context) async {
    try {
      final res = await DioClient.dio.get('/usuarios/api/auth/check');
      final data = res.data;

      final isOk = data['isValid'] == true || data['success'] == true;
      final esUsuario = data['tipo'] == 'usuario';

      if (isOk && esUsuario) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SolicitudFormularioPage(mascota: mascota),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mascota: ${mascota['nombre']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  mascota['foto'] != null && mascota['foto'].toString().isNotEmpty
                      ? 'https://moviltika-production.up.railway.app/uploads/${mascota['foto']}'
                      : 'https://via.placeholder.com/200',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Nombre: ${mascota['nombre']}', style: const TextStyle(fontSize: 18)),
            Text('Edad: ${mascota['edad']} años', style: const TextStyle(fontSize: 18)),
            Text('Especie: ${mascota['especie']}', style: const TextStyle(fontSize: 18)),
            Text('Género: ${mascota['genero']}', style: const TextStyle(fontSize: 18)),
            Text('Tamaño: ${mascota['tamanio']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(mascota['descripcion'] ?? '-', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => irAlFormulario(context),
                icon: const Icon(Icons.pets),
                label: const Text('Solicitar Adopción'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
