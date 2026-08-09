import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estado 1: Contador
  int _contadorFavoritos = 0;

  // Estado 2: Cambio de color (alterna entre rosa y morado)
  bool _esColorRosa = true;

  // Estado 3: Mostrar u ocultar componentes
  bool _mostrarDetalles = false;

  @override
  Widget build(BuildContext context) {
    // Definimos el color según el estado 2
    final Color colorActual = _esColorRosa ? Colors.pinkAccent : Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: colorActual,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar con el color del estado 2
            CircleAvatar(
              radius: 50,
              backgroundColor: colorActual,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              'Usuario1',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ingeniería en Tecnologías de la Información',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),

            // --- EJEMPLO 1: CONTADOR ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text('1. Manejo de Estado: Contador de Favoritos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Favoritos guardados: $_contadorFavoritos',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: colorActual),
                      onPressed: () {
                        setState(() {
                          _contadorFavoritos++;
                        });
                      },
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text('Añadir Favorito', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- EJEMPLO 2: CAMBIO DE COLOR ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text('2. Manejo de Estado: Cambio de Color',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: colorActual),
                      onPressed: () {
                        setState(() {
                          _esColorRosa = !_esColorRosa; // Cambia el booleano del color
                        });
                      },
                      child: const Text('Cambiar Tema de Color', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- EJEMPLO 3: MOSTRAR U OCULTAR COMPONENTES ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text('3. Manejo de Estado: Mostrar / Ocultar',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mostrarDetalles = !_mostrarDetalles; // Alterna visibilidad
                        });
                      },
                      child: Text(_mostrarDetalles ? 'Ocultar Información' : 'Ver Información Oculta'),
                    ),
                    // Componente condicional
                    if (_mostrarDetalles) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.pink.shade50,
                        child: const Text(
                          '¡Información secreta revelada! Estudiante activa de ingeniería.',
                          style: TextStyle(color: Colors.pinkAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}