import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/dio_client.dart';

class AgregarMascotaPage extends StatefulWidget {
  const AgregarMascotaPage({super.key});

  @override
  State<AgregarMascotaPage> createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final especieController = TextEditingController();
  final edadController = TextEditingController();
  final descripcionController = TextEditingController();

  String? genero;
  String? tamanio;
  File? imagen;
  String mensaje = '';
  bool cargando = false;

  final tamanios = ['pequeño', 'mediano', 'grande'];
  final generos = ['macho', 'hembra'];

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
  }

  Future<void> enviarFormulario() async {
    if (!_formKey.currentState!.validate() || imagen == null) {
      setState(() {
        mensaje = 'Completa todos los campos y selecciona una imagen';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final authResponse = await DioClient.dio.get('/refugios/api/auth/check');
      final tipo = authResponse.data['tipo'];
      final idcentro = authResponse.data['userId'];

      if (authResponse.data['isValid'] != true || tipo != 'refugio') {
        setState(() => mensaje = 'Sesión no válida');
        return;
      }

      final formData = FormData.fromMap({
        'nombre': nombreController.text,
        'tamanio': tamanio,
        'especie': especieController.text,
        'edad': edadController.text,
        'genero': genero,
        'descripcion': descripcionController.text,
        'idcentro': idcentro,
        'foto': await MultipartFile.fromFile(imagen!.path, filename: 'mascota.jpg'),
      });

      final response = await DioClient.dio.post('/refugios/mascotas/register', data: formData);

      if (response.data['success'] == true) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/refugio');
          }
        });
      } else {
        setState(() => mensaje = response.data['message'] ?? 'Error al registrar mascota');
      }
    } catch (e) {
      setState(() => mensaje = 'Error al enviar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Mascota')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: especieController,
                      decoration: const InputDecoration(labelText: 'Especie'),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: tamanio,
                      decoration: const InputDecoration(labelText: 'Tamaño'),
                      items: tamanios
                          .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (value) => setState(() => tamanio = value),
                      validator: (value) => value == null ? 'Selecciona un tamaño' : null,
                    ),
                    TextFormField(
                      controller: edadController,
                      decoration: const InputDecoration(labelText: 'Edad'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo requerido';
                        if (int.tryParse(value) == null) return 'Debe ser un número';
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: genero,
                      decoration: const InputDecoration(labelText: 'Género'),
                      items: generos
                          .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (value) => setState(() => genero = value),
                      validator: (value) => value == null ? 'Selecciona un género' : null,
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: seleccionarImagen,
                      child: const Text('Seleccionar Foto'),
                    ),
                    if (imagen != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.file(imagen!, width: 150, height: 150),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: enviarFormulario,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('Registrar Mascota'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/refugio');
                          }
                        });
                      },
                      child: const Text('Volver al Panel del Refugio'),
                    ),
                    const SizedBox(height: 10),
                    if (mensaje.isNotEmpty)
                      Text(
                        mensaje,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
