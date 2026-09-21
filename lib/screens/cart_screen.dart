import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Lista simulada de productos en el carrito
  final List<Map<String, dynamic>> _cartItems = [
    {'nombre': 'Camisa de Fútbol Oficial', 'precio': 650.0, 'cantidad': 1},
    {'nombre': 'Balón de Fútbol Profesional', 'precio': 450.0, 'cantidad': 1},
    {'nombre': 'Medias Deportivas', 'precio': 150.0, 'cantidad': 1},
  ];

  double get _subtotal {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['precio'] as double) * (item['cantidad'] as int);
    }
    return total;
  }

  int get _totalProductos {
    int total = 0;
    for (var item in _cartItems) {
      total += (item['cantidad'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool aplicaPromo = _totalProductos >= 3;
    double descuento = aplicaPromo ? _subtotal * 0.15 : 0.0; // 15% de descuento por 3 a más productos
    double totalFinal = _subtotal - descuento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras 🛒'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner indicador de la promoción de 3 productos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: aplicaPromo ? Colors.pink.shade100 : Colors.grey.shade200,
            child: Row(
              children: [
                Icon(
                  aplicaPromo ? Icons.local_offer : Icons.info_outline,
                  color: aplicaPromo ? Colors.pinkAccent : Colors.grey.shade700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    aplicaPromo
                        ? '🔥 ¡Felicidades! Tienes 3 o más productos. ¡Se ha aplicado tu 15% de descuento especial!'
                        : '💡 ¡Agrega ${_cartItems.isEmpty ? 3 : (3 - _totalProductos)} producto(s) más para activar la súper promoción de 3 en adelante!',
                    style: TextStyle(
                      color: aplicaPromo ? Colors.pink.shade900 : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Tu carrito está vacío 🛍️',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag, color: Colors.pinkAccent),
                          ),
                          title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Precio: L. ${item['precio']} x ${item['cantidad']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _cartItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Sección de totales y botón de pago
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 15)),
                    Text('L. ${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15)),
                  ],
                ),
                if (aplicaPromo) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Descuento (Promo 3+):', style: TextStyle(fontSize: 15, color: Colors.pinkAccent)),
                      Text('- L. ${descuento.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: Colors.pinkAccent)),
                    ],
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a Pagar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'L. ${totalFinal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _cartItems.isEmpty
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Compra procesada con éxito en la tienda! 🎉')),
                          );
                        },
                  child: const Text(
                    'Confirmar Pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}