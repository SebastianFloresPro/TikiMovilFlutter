import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class SolicitudFormularioPage extends StatefulWidget {
  final Map<String, dynamic>? mascota;

  const SolicitudFormularioPage({super.key, this.mascota});

  @override
  State<SolicitudFormularioPage> createState() => _SolicitudFormularioPageState();
}

class _SolicitudFormularioPageState extends State<SolicitudFormularioPage> {
  List<dynamic> mascotas = [];
  int? selectedMascotaId;
  String motivo = '';
  String experiencia = '';
  String mensaje = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMascotas();
  }

  Future<void> cargarMascotas() async {
    try {
      final res = await DioClient.dio.get('/mascotas');
      if (res.data['success'] == true) {
        setState(() {
          mascotas = res.data['mascotas'];
          cargando = false;
          if (widget.mascota != null) {
            selectedMascotaId = widget.mascota!['idmascota'];
          }
        });
      } else {
        setState(() {
          mensaje = 'Error al cargar mascotas.';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión al cargar.';
        cargando = false;
      });
    }
  }

  void enviarSolicitud() async {
    if (selectedMascotaId == null || motivo.isEmpty || experiencia.isEmpty) {
      setState(() {
        mensaje = 'Por favor, completa todos los campos.';
      });
      return;
    }

    try {
      final res = await DioClient.dio.post(
        '/mascotas/solicitar-adopcion',
        data: {
          'mascotaId': selectedMascotaId,
          'motivo': motivo,
          'experiencia': experiencia,
        },
      );
      if (res.data['success'] == true) {
        setState(() {
          mensaje = '✅ Solicitud enviada con éxito.';
          motivo = '';
          experiencia = '';
          selectedMascotaId = null;
        });
      } else {
        setState(() {
          mensaje = 'Error al enviar solicitud.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión al enviar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud de Adopción')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: selectedMascotaId,
                    isExpanded: true,
                    hint: const Text('Selecciona una mascota'),
                    items: mascotas.map<DropdownMenuItem<int>>((mascota) {
                      return DropdownMenuItem<int>(
                        value: mascota['idmascota'],
                        child: Text('${mascota['nombre']} (${mascota['especie']})'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedMascotaId = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (selectedMascotaId != null) ..._buildMascotaInfo(),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Motivo de adopción'),
                    maxLines: 3,
                    onChanged: (val) => motivo = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Experiencia con mascotas'),
                    maxLines: 3,
                    onChanged: (val) => experiencia = val,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: enviarSolicitud,
                    child: const Text('Enviar Solicitud'),
                  ),
                  const SizedBox(height: 10),
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildMascotaInfo() {
    final mascota = mascotas.firstWhere(
      (m) => m['idmascota'] == selectedMascotaId,
      orElse: () => null,
    );

    if (mascota == null) return [];

    final fotoUrl = mascota['foto'] != null
        ? (mascota['foto'].toString().startsWith('/uploads/')
            ? 'https://moviltika-production.up.railway.app${mascota['foto']}'
            : 'https://moviltika-production.up.railway.app/uploads/${mascota['foto']}')
        : null;

    return [
      const SizedBox(height: 10),
      if (fotoUrl != null)
        Image.network(fotoUrl, height: 150, fit: BoxFit.cover),
      const SizedBox(height: 10),
      Text('Edad: ${mascota['edad'] ?? '-'} años'),
      Text('Descripción: ${mascota['descripcion'] ?? 'Sin descripción'}'),
    ];
  }
}
