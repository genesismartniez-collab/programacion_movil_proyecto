import 'package:flutter/material.dart';
import '../Producto.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  CatalogScreen({super.key});

  final List<Producto> listaProductos = [
    Producto(
      id: '1',
      nombre: 'Vestido Casual Rosado',
      categoria: 'Ropa',
      precio: 450.00,
      descripcion: 'Vestido cómodo y fresco, ideal para cualquier ocasión.',
    ),
    Producto(
      id: '2',
      nombre: 'Zapatillas Urbanas',
      categoria: 'Calzado',
      precio: 750.00,
      descripcion: 'Calzado moderno, suave y de excelente durabilidad.',
    ),
    Producto(
      id: '3',
      nombre: 'Perfume Sweet Bloom',
      categoria: 'Perfumería',
      precio: 580.00,
      descripcion: 'Fragancia duradera con notas florales y dulces.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
      ),
      body: ListView.builder(
        itemCount: listaProductos.length,
        itemBuilder: (context, index) {
          final producto = listaProductos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.pinkAccent),
              title: Text(
                producto.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${producto.categoria} - L. ${producto.precio.toStringAsFixed(2)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(producto: producto),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}