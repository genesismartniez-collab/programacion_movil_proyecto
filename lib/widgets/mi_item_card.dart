import 'package:flutter/material.dart';

// Widget personalizado reutilizable para mostrar un producto o ítem en forma de tarjeta
class MiItemCard extends StatelessWidget {
  // Declaración de las variables o propiedades que recibirá el componente
  final String titulo;
  final String subtitulo;
  final double precio;
  final String categoria;
  final String? imagenUrl;         
  final bool mostrarBadge;         
  final VoidCallback onTap;
  final VoidCallback onAccionSecundaria; 
  final Color colorAccento;        

  // Constructor con parámetros requeridos y valores por defecto
  const MiItemCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
    required this.categoria,
    this.imagenUrl,
    this.mostrarBadge = false,
    required this.onTap,
    required this.onAccionSecundaria,
    this.colorAccento = Colors.pinkAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Sombreado de la tarjeta para darle profundidad
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordes redondeados modernos
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      // InkWell permite que la tarjeta responda al tacto con una animación bonita
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Contenedor decorativo para el ícono de la izquierda
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorAccento.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: colorAccento,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Columna central que contiene textos (título, subtítulo y precio)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Título principal del producto
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        // Etiqueta opcional "HOT" si se indica que debe mostrarse
                        if (mostrarBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorAccento,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'HOT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo o descripción corta
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    // Precio formateado con dos decimales y el símbolo de Lempiras (L.)
                    Text(
                      'L. ${precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: colorAccento,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de acción secundaria situado a la derecha (por ejemplo, para eliminar)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onAccionSecundaria,
              ),
            ],
          ),
        ),
      ),
    );
  }
}