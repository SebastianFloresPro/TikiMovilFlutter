import 'package:flutter/material.dart';
import 'helpers/dio_client.dart';
import 'pages/index_page.dart';
import 'pages/refugios_page.dart';
import 'pages/buscar_page.dart';
import 'pages/login_page.dart';
import 'pages/about_page.dart';
import 'pages/usuario_page.dart';
import 'pages/loginrefugio_page..dart';
import 'pages/refugio_page.dart';

void main() {
  DioClient.init(); // Iniciar Dio y CookieManager
  runApp(const AppLauncher());
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainWrapper(),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  String? initialRoute;

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    try {
      final response = await DioClient.dio.get('/usuarios/api/auth/check');
      final data = response.data;

      print('Verificación: $data');

      if (data['isValid'] == true && data['tipo'] == 'usuario') {
        initialRoute = '/usuario';
      } else {
        initialRoute = '/login';
      }
    } catch (e) {
      print('Error al verificar sesión: $e');
      initialRoute = '/login';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (initialRoute == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute!,
      routes: {
        '/': (context) => const IndexPage(),
        '/refugios': (context) => const RefugiosPage(),
        '/buscar': (context) => const BuscarPage(),
        '/login': (context) => const LoginPage(),
        '/about': (context) => const AboutPage(),
        '/usuario': (context) => const UsuarioPage(),
        '/loginrefugio': (context) => const LoginRefugiosPage(),
        '/refugio': (context) => const RefugioPage(),
      },
    );
  }
}
