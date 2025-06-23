import 'package:flutter/material.dart';
import '../widgets/tiki_navbar.dart'; // Importa la nueva barra adaptada

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre TikaPaw')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              '🐾 TikaPaw',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'TikaPaw es una plataforma dedicada a conectar personas con refugios de animales para fomentar la adopción responsable.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '🌎 Nuestra Misión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Dar visibilidad a refugios y mascotas que buscan un hogar, promoviendo el bienestar animal.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '🤝 Colabora con Nosotros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Si tienes un refugio o quieres ayudar, únete a nuestra comunidad y haz la diferencia.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TikiNavBar(
        selectedIndex: -1, // No hay una sección activa exacta
        context: context,  // Necesario para verificación
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
