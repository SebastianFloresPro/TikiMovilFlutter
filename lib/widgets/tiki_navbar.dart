import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class TikiNavBar extends StatelessWidget {
  final int selectedIndex;
  final BuildContext context;

  const TikiNavBar({
    super.key,
    required this.selectedIndex,
    required this.context,
  });

  Future<void> _onItemTapped(int index) async {
    if (index == 4) {
      final tipoSesion = await _verificarTipoSesion();
      if (!context.mounted) return;

      if (tipoSesion == 'usuario') {
        Navigator.pushReplacementNamed(context, '/usuario');
      } else if (tipoSesion == 'refugio') {
        Navigator.pushReplacementNamed(context, '/refugio');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (index == 0) {
      Navigator.pushReplacementNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/refugios');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/buscar');
    }
  }

  Future<String?> _verificarTipoSesion() async {
    try {
      final usuarioResponse = await DioClient.dio.get('/usuarios/api/auth/check');
      final data = usuarioResponse.data;

      if (data['isValid'] == true && data['tipo'] == 'usuario') {
        return 'usuario';
      }
    } catch (_) {}

    try {
      final refugioResponse = await DioClient.dio.get('/refugios/api/auth/check');
      final data = refugioResponse.data;

      if (data['isValid'] == true && data['tipo'] == 'refugio') {
        return 'refugio';
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _onItemTapped(0),
            color: selectedIndex == 0 ? Colors.teal : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.local_hospital),
            onPressed: () => _onItemTapped(1),
            color: selectedIndex == 1 ? Colors.teal : Colors.grey,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _onItemTapped(3),
            color: selectedIndex == 3 ? Colors.teal : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _onItemTapped(4),
            color: selectedIndex == 4 ? Colors.teal : Colors.grey,
          ),
        ],
      ),
    );
  }
}
