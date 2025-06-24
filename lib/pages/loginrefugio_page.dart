import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class LoginRefugiosPage extends StatefulWidget {
  const LoginRefugiosPage({super.key});

  @override
  State<LoginRefugiosPage> createState() => _LoginRefugiosPageState();
}

class _LoginRefugiosPageState extends State<LoginRefugiosPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String mensaje = '';
  bool cargando = false;

  Future<void> login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final response = await DioClient.dio.post(
        '/refugios/login',
        data: {
          'correo': correoController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final body = response.data;

      print('Código de estado: ${response.statusCode}');
      print('Respuesta JSON: $body');

      if (response.statusCode == 200 && body['success'] == true) {
        Navigator.pushReplacementNamed(context, '/refugio');
      } else {
        setState(() {
          mensaje = 'Error: ${body['message'] ?? 'No se pudo iniciar sesión'}';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de red: $e';
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
      appBar: AppBar(title: const Text('Login Refugios - TikiTiki')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Iniciar Sesión como Refugio'),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Volver al Login de Usuarios'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/crearcuenta');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Crear Cuenta de Usuario'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registrarrefugio');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Registrar Refugio'),
            ),
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
