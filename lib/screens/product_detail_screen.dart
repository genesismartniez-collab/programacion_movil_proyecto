import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/cart_model.dart'; // <-- 1. Importamos el modelo global del carrito

class ProductDetailScreen extends StatefulWidget {
  final Producto producto;

  const ProductDetailScreen({super.key, required this.producto});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Variables para guardar lo que el usuario va seleccionando
  String? tallaSeleccionada;
  String? colorSeleccionado;

  @override
  void initState() {
    super.initState();
    // Seleccionamos por defecto la primera opción de cada lista si existen
    if (widget.producto.tallas.isNotEmpty) {
      tallaSeleccionada = widget.producto.tallas.first;
    }
    if (widget.producto.colores.isNotEmpty) {
      colorSeleccionado = widget.producto.colores.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.producto.nombre,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen o contenedor principal del producto estilo estético
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 90,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.producto.categoria.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.producto.nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L. ${widget.producto.precio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.producto.descripcion,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),

            // SECCIÓN DE TALLAS INTERACTIVAS
            const Text(
              'Selecciona la Talla:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: widget.producto.tallas.map((talla) {
                final isSelected = tallaSeleccionada == talla;
                return ChoiceChip(
                  label: Text(talla),
                  selected: isSelected,
                  selectedColor: Colors.pinkAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    setState(() {
                      tallaSeleccionada = talla;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // SECCIÓN DE COLORES INTERACTIVOS
            const Text(
              'Selecciona el Color:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: widget.producto.colores.map((color) {
                final isSelected = colorSeleccionado == color;
                return ChoiceChip(
                  label: Text(color),
                  selected: isSelected,
                  selectedColor: Colors.pinkAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    setState(() {
                      colorSeleccionado = color;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // BOTÓN DE COMPRA / AGREGAR AL CARRITO
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // 2. Agregamos el producto de forma real al carrito global
                  cartModel.addItem({
                    'nombre': '${widget.producto.nombre} (${tallaSeleccionada ?? 'Única'}, ${colorSeleccionado ?? 'Estándar'})',
                    'precio': widget.producto.precio,
                    'cantidad': 1,
                  });

                  // Mensaje de confirmación visual
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡Agregado al carrito! Talla: $tallaSeleccionada, Color: $colorSeleccionado 🛍️',
                      ),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
                child: const Text(
                  'AGREGAR AL CARRITO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}