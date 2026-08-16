import 'package:flutter/material.dart';

class MiItemCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final double precio;
  final String categoria;
  final String? imagenUrl;        
  final bool mostrarBadge;         
  final VoidCallback onTap;
  final VoidCallback onAccionSecundaria; 
  final Color colorAccento;         

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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
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
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
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