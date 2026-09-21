import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categorias = [
      {'titulo': 'Camisetas de Fútbol', 'icon': Icons.sports_soccer, 'color': Colors.pink},
      {'titulo': 'Calzado Deportivo', 'icon': Icons.directions_run, 'color': Colors.purple},
      {'titulo': 'Accesorios y Balones', 'icon': Icons.sports, 'color': Colors.orange},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías - Variedades Genali'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cat['color'].withOpacity(0.2),
                child: Icon(cat['icon'], color: cat['color']),
              ),
              title: Text(
                cat['titulo'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Aquí puedes filtrar el catálogo según la categoría seleccionada
              },
            ),
          );
        },
      ),
    );
  }
}