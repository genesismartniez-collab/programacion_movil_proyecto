import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../widgets/drawer_menu.dart';

class CatalogScreen extends StatefulWidget {
  final String rolUsuario;
  final String correoUsuario;

  const CatalogScreen({
    super.key,
    required this.rolUsuario,
    required this.correoUsuario,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _categoriaSeleccionada = 'Todos';

  final List<String> _categorias = [
    'Todos', 'Calzado', 'Accesorios', 'Vestido Dama', 'Caballero',
    'Niño', 'Niña', 'Fútbol', 'Camiseta Deportiva', 'Perfumería'
  ];

  final List<Map<String, dynamic>> _productos = [
    {
      'nombre': 'Camiseta Oficial Selección',
      'categoria': 'Fútbol',
      'icono': Icons.sports_soccer,
      'tallas': ['S', 'M', 'L', 'XL'],
      'esFavorito': true,
    },
    {
      'nombre': 'Tenis Deportivos Urbanos',
      'categoria': 'Calzado',
      'icono': Icons.roller_skating,
      'tallas': ['38', '39', '40', '41', '42'],
      'esFavorito': true,
    },
    {
      'nombre': 'Vestido Casual Rosado',
      'categoria': 'Vestido Dama',
      'icono': Icons.checkroom,
      'tallas': ['XS', 'S', 'M', 'L'],
      'esFavorito': false,
    },
    {
      'nombre': 'Perfume Floral Elegante',
      'categoria': 'Perfumería',
      'icono': Icons.eco,
      'tallas': ['50ml', '100ml'],
      'esFavorito': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _inicializarOneSignal();
  }

  void _inicializarOneSignal() {
    // App ID integrado correctamente de tu cuenta de OneSignal
    OneSignal.initialize("fd143feb-5d7e-4f4e-8494-e7016ca7935b");
    OneSignal.Notifications.requestPermission(true);
  }

  void _venderTalla(int indexProducto, String talla) {
    setState(() {
      _productos[indexProducto]['tallas'].remove(talla);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 Notificación: ¡Venta registrada! Talla $talla descontada del inventario.'),
        backgroundColor: Colors.pinkAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = _categoriaSeleccionada == 'Todos'
        ? _productos
        : _productos.where((p) => p['categoria'] == _categoriaSeleccionada).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo y Stock - Variedades Genali 🌸'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerMenu(correoUsuario: widget.correoUsuario, rolUsuario: widget.rolUsuario),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                final esSeleccionada = _categoriaSeleccionada == categoria;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                  child: ChoiceChip(
                    label: Text(categoria),
                    selected: esSeleccionada,
                    selectedColor: Colors.pinkAccent,
                    labelStyle: TextStyle(
                      color: esSeleccionada ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _categoriaSeleccionada = categoria;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(child: Text('No hay productos disponibles en esta categoría.'))
                : ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      final realIndex = _productos.indexOf(producto);
                      final List<String> tallas = producto['tallas'];
                      final bool esFavorito = producto['esFavorito'];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.pink[100],
                                    radius: 25,
                                    child: Icon(producto['icono'], size: 28, color: Colors.pinkAccent),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                producto['nombre'],
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            if (esFavorito)
                                              const Chip(
                                                avatar: Icon(Icons.star, color: Colors.amber, size: 16),
                                                label: Text('Lo más vendido', style: TextStyle(fontSize: 10)),
                                                backgroundColor: Color(0xFFFFF8E1),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                          ],
                                        ),
                                        Text(producto['categoria'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              const Text(
                                'Inventario de Tallas Disponibles (Haz clic para vender y descontar):',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              tallas.isEmpty
                                  ? const Text(
                                      '¡Agotado en todas las tallas!',
                                      style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                    )
                                  : Wrap(
                                      spacing: 8.0,
                                      children: tallas.map((talla) {
                                        return ActionChip(
                                          label: Text(talla),
                                          backgroundColor: Colors.pink[50],
                                          labelStyle: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                                          onPressed: () => _venderTalla(realIndex, talla),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}