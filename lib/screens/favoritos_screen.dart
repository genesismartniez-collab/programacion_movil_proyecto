import 'package:flutter/material.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favoritos = [
      {'nombre': 'Camiseta Oficial Selección', 'categoria': 'Fútbol', 'icono': Icons.sports_soccer, 'vendidos': '45 unidades'},
      {'nombre': 'Tenis Deportivos Urbanos', 'categoria': 'Calzado', 'icono': Icons.roller_skating, 'vendidos': '30 pares'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos / Lo más vendido ⭐'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          final prod = favoritos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber[100],
                child: Icon(prod['icono'], color: Colors.amber[800]),
              ),
              title: Text(prod['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Categoría: ${prod['categoria']}'),
              trailing: Chip(
                label: Text(prod['vendidos'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.pinkAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}