import 'package:flutter/material.dart';
import '../widgets/product_card.dart'; // Importamos tu widget reutilizable
import 'product_detail_screen.dart';
import '../models/producto.dart';

class PromosScreen extends StatelessWidget {
  const PromosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = const Color(0xFFF7F4F0);
    final Color colorRosaOscuro = const Color(0xFFD81B60);

    // Creamos un producto de ejemplo para la sección de promos
    final productoPromo = Producto(
      id: 'promo1',
      nombre: 'Vestido Especial en Oferta',
      categoria: 'Promociones',
      precio: 350.00,
      descripcion: 'Edición limitada con descuento especial de temporada.',
      tallas: ['S', 'M', 'L'],
      colores: ['Rosa Pastel'],
    );

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Promociones Especiales 🔥',
          style: TextStyle(
            color: colorRosaOscuro,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Aprovecha los descuentos del mes!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // AQUÍ ESTÁ EL USO DE TU WIDGET REUTILIZABLE EN LA SEGUNDA PANTALLA
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 160,
                    child: ProductCard(
                      nombre: productoPromo.nombre,
                      precio: productoPromo.precio,
                      imagenUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(producto: productoPromo),
                          ),
                        );
                      },
                      onFavorite: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Promoción agregada a favoritos!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}