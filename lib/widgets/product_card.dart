import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String nombre;
  final double precio;
  final String imagenUrl;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const ProductCard({
    super.key,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(imagenUrl, height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                  ),
                  Text('L${precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                  if (onFavorite != null)
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.pink, size: 18),
                      onPressed: onFavorite,
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