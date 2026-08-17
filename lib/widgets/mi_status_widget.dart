import 'package:flutter/material.dart';

class MiStatusWidget extends StatelessWidget {
  final String estado; 
  final String tituloResumen;
  final int cantidad;

  const MiStatusWidget({
    super.key,
    required this.estado,
    required this.tituloResumen,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context) {
    Color colorEstado;
    IconData iconoEstado;
    String textoEstado;

    switch (estado.toLowerCase()) {
      case 'activo':
        colorEstado = Colors.green;
        iconoEstado = Icons.check_circle_rounded;
        textoEstado = 'Disponible';
        break;
      case 'pendiente':
        colorEstado = Colors.orange;
        iconoEstado = Icons.access_time_rounded;
        textoEstado = 'En Revisión';
        break;
      case 'agotado':
      default:
        colorEstado = Colors.redAccent;
        iconoEstado = Icons.error_outline_rounded;
        textoEstado = 'Agotado';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorEstado.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorEstado.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorEstado.withOpacity(0.2),
            radius: 24,
            child: Icon(iconoEstado, color: colorEstado, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloResumen,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total registros: $cantidad',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              textoEstado,
              style: TextStyle(
                color: colorEstado,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}