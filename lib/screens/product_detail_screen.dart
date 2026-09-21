import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? producto;
  final String rol; // 'gerente' o 'empleado'

  const ProductDetailScreen({
    super.key,
    this.producto,
    required this.rol,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _stockActual;

  @override
  void initState() {
    super.initState();
    _stockActual = widget.producto?['stock'] ?? 10;
  }

  void _registrarVenta() {
    if (_stockActual > 0) {
      setState(() {
        _stockActual--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Venta registrada! Stock actualizado en tiempo real ⚽📉'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay stock disponible de este producto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.producto?['nombre'] ?? 'Camiseta / Calzado Deportivo';
    final categoria = widget.producto?['categoria'] ?? 'Artículos Deportivos';
    final precio = widget.producto?['precio'] ?? 850.0;
    bool esGerente = widget.rol == 'gerente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.pinkAccent.shade100, width: 2),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(categoria, style: const TextStyle(color: Colors.pink)),
              backgroundColor: Colors.pink.shade50,
            ),
            const SizedBox(height: 16),
            Text(
              'Precio: L. ${precio.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Existencias en Inventario (Stock): ', style: TextStyle(fontSize: 16)),
                Text(
                  '$_stockActual unidades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _stockActual > 0 ? Colors.green.shade700 : Colors.red,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: esGerente ? Colors.purple : Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: esGerente
                    ? () {
                        setState(() {
                          _stockActual += 5;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Se han sumado 5 unidades al inventario (Gerente).')),
                        );
                      }
                    : _registrarVenta,
                child: Text(
                  esGerente ? 'Reabastecer Stock (+5)' : 'Registrar Venta (-1 Stock)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}