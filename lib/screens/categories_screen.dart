import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String? categoriaFiltro;

  const CatalogScreen({super.key, this.categoriaFiltro});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroBusqueda = "";

  // Lista actualizada con productos clasificados en tus nuevas categorías
  final List<Producto> listaProductos = [
    Producto(
      id: '1',
      nombre: 'Vestido Corto Casual Rosado',
      categoria: 'Dama',
      precio: 450.00,
      descripcion: 'Vestido tierno y fresco, ideal para un look veraniego y chic.',
      tallas: ['XS', 'S', 'M', 'L'],
      colores: ['Rosa', 'Blanco', 'Negro'],
    ),
    Producto(
      id: '2',
      nombre: 'Vestido de Noche Elegante',
      categoria: 'Ropa Elegante',
      precio: 1250.00,
      descripcion: 'Vestido largo sofisticado para eventos especiales.',
      tallas: ['S', 'M', 'L'],
      colores: ['Negro', 'Rojo', 'Vino'],
    ),
    Producto(
      id: '3',
      nombre: 'Perfume Victoria’s Secret',
      categoria: 'Dama',
      precio: 680.00,
      descripcion: 'Fragancia dulce y duradera con notas florales irresistibles.',
      tallas: ['Única (250ml)'],
      colores: ['Rosa Clásico'],
    ),
    Producto(
      id: '4',
      nombre: 'Tacones Altos de Aguja',
      categoria: 'Dama',
      precio: 890.00,
      descripcion: 'Tacones elegantes para estilizar cualquier outfit de noche.',
      tallas: ['35', '36', '37', '38', '39'],
      colores: ['Nude', 'Negro', 'Plateado'],
    ),
    Producto(
      id: '5',
      nombre: 'Zapatillas Urbanas',
      categoria: 'Novedades',
      precio: 750.00,
      descripcion: 'Calzado moderno, cómodo y en tendencia estilo Pinterest.',
      tallas: ['36', '37', '38', '39'],
      colores: ['Blanco/Rosa', 'Blanco Puro'],
    ),
    Producto(
      id: '6',
      nombre: 'Camisa Formal de Caballero',
      categoria: 'Caballero',
      precio: 480.00,
      descripcion: 'Camisa elegante de cuello formal para hombre.',
      tallas: ['S', 'M', 'L', 'XL'],
      colores: ['Blanco', 'Azul Cielo'],
    ),
    Producto(
      id: '7',
      nombre: 'Crocs Clásicos Rosados',
      categoria: 'Dama',
      precio: 650.00,
      descripcion: 'Cómodos y ligeros, ideales para estar en casa o salir.',
      tallas: ['36', '37', '38', '39'],
      colores: ['Rosa', 'Blanco'],
    ),
    Producto(
      id: '8',
      nombre: 'Conjunto Deportivo Infantil',
      categoria: 'Niño',
      precio: 520.00,
      descripcion: 'Ropa deportiva cómoda para niños.',
      tallas: ['6-8 años'],
      colores: ['Azul', 'Gris'],
    ),
    Producto(
      id: '9',
      nombre: 'Vestidito Casual de Niña',
      categoria: 'Niña',
      precio: 390.00,
      descripcion: 'Vestido tierno con detalles florales.',
      tallas: ['4-6 años'],
      colores: ['Rosa Pastel'],
    ),
    Producto(
      id: '10',
      nombre: 'Organizador de Maquillaje',
      categoria: 'Hogar',
      precio: 450.00,
      descripcion: 'Acabado acrílico transparente y elegante.',
      tallas: ['Estándar'],
      colores: ['Transparente'],
    ),
    Producto(
      id: '11',
      nombre: 'Balón de Fútbol Pro',
      categoria: 'Fútbol',
      precio: 600.00,
      descripcion: 'Balón resistente para cancha sintética y natural.',
      tallas: ['Número 5'],
      colores: ['Blanco/Negro'],
    ),
  ];

  final Color colorFondo = const Color(0xFFF7F4F0);
  final Color colorRosaSuave = const Color(0xFFFCE4EC);
  final Color colorRosaOscuro = const Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    // Filtro combinado por categoría y barra de búsqueda
    final productosAMostrar = listaProductos.where((p) {
      final coincideCategoria = widget.categoriaFiltro == null || p.categoria == widget.categoriaFiltro;
      final coincideBusqueda = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorRosaOscuro),
        title: Text(
          widget.categoriaFiltro ?? 'Catálogo General',
          style: TextStyle(
            color: colorRosaOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtroBusqueda = value),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: colorRosaOscuro),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Cuadrícula de productos
          Expanded(
            child: productosAMostrar.isEmpty
                ? Center(
                    child: Text(
                      'No hay productos en esta sección todavía 🛍️',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GridView.builder(
                      itemCount: productosAMostrar.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        final producto = productosAMostrar[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(producto: producto),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    color: colorRosaSuave,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: colorRosaOscuro,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  producto.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  producto.categoria,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'L. ${producto.precio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: colorRosaOscuro,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}