import 'package:flutter/material.dart';
import 'helpers/dio_client.dart';

// Páginas principales
import 'pages/index_page.dart' as index;
import 'pages/buscar_page.dart' as buscar;
import 'pages/login_page.dart';
import 'pages/about_page.dart';
import 'pages/usuario_page.dart';
import 'pages/loginrefugio_page.dart';
import 'pages/refugio_page.dart';
import 'pages/agregarmascotapage.dart';
import 'pages/mascotainfo_page.dart';
import 'pages/refugios_page.dart';
import 'pages/refugioinformacion_page.dart' as info;
import 'pages/mascotainfosolicitud.dart';
import 'pages/solicitudes_page.dart';

void main() {
  DioClient.init();
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

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  Future<String> _determinarRutaInicial() async {
    try {
      final response = await DioClient.dio.get('/usuarios/api/auth/check');
      final data = response.data;

      if (data['isValid'] == true && data['tipo'] == 'usuario') {
        return '/usuario';
      } else {
        return '/login';
      }
    } catch (e) {
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determinarRutaInicial(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: snapshot.data!,
          routes: {
            '/': (context) => const index.IndexPage(),
            '/refugios': (context) => const RefugiosPage(),
            '/buscar': (context) => const buscar.BuscarPage(),
            '/login': (context) => const LoginPage(),
            '/about': (context) => const AboutPage(),
            '/usuario': (context) => const UsuarioPage(),
            '/loginrefugio': (context) => const LoginRefugiosPage(),
            '/refugio': (context) => const RefugioPage(),
            '/registrarmascota': (context) => const AgregarMascotaPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/mascotainfo') {
              final mascota = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => MascotaInfoPage(mascota: mascota),
              );
            }

            if (settings.name == '/refugioinfo') {
              final refugio = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => info.RefugioInformacionPage(refugio: refugio),
              );
            }

            if (settings.name == '/mascotainfosolicitud') {
              final mascota = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => MascotaInfoSolicitudPage(mascota: mascota),
              );
            }

            if (settings.name == '/formulariosolicitud') {
              final mascota = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => SolicitudFormularioPage(mascota: mascota),
              );
            }

            return null;
          },
        );
      },
    );
  }
}
