import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        '/usuarios/login',
        data: {
          'correo': correoController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final body = response.data;

      print('Código de estado: ${response.statusCode}');
      print('Respuesta JSON: $body');

      if (response.statusCode == 200 && body['success'] == true) {
        Navigator.pushReplacementNamed(context, '/usuario');
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
      appBar: AppBar(title: const Text('Login - TikiTiki')),
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
                    child: const Text('Iniciar Sesión'),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/crearcuenta');
              },
              child: const Text('Crear Cuenta'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registrarrefugio');
              },
              child: const Text('Registrar Refugio'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/loginrefugio');
              },
              child: const Text('Iniciar sesión como Refugio'),
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
