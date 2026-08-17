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
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = widget.categoriaFiltro;
  }

  // Estado local para los favoritos (ID del producto -> es favorito)
  final Set<String> _favoritosIds = {};

  final List<Producto> listaProductos = [
    Producto(id: '1', nombre: 'Vestido Corto Casual Rosado', categoria: 'Dama', precio: 450.00, descripcion: 'Vestido tierno y fresco.', tallas: ['XS', 'S', 'M', 'L'], colores: ['Rosa', 'Blanco']),
    Producto(id: '2', nombre: 'Vestido de Noche Elegante', categoria: 'Ropa Elegante', precio: 1250.00, descripcion: 'Vestido largo sofisticado.', tallas: ['S', 'M', 'L'], colores: ['Negro', 'Rojo']),
    Producto(id: '3', nombre: 'Perfume Victoria’s Secret', categoria: 'Dama', precio: 680.00, descripcion: 'Fragancia dulce y duradera.', tallas: ['250ml'], colores: ['Rosa']),
    Producto(id: '4', nombre: 'Tacones Altos de Aguja', categoria: 'Dama', precio: 890.00, descripcion: 'Tacones elegantes de noche.', tallas: ['36', '37', '38'], colores: ['Nude']),
    Producto(id: '5', nombre: 'Conjunto Deportivo Chic', categoria: 'Ropa Casual', precio: 550.00, descripcion: 'Cómodo y a la moda para entrenar o salir.', tallas: ['S', 'M', 'L'], colores: ['Gris', 'Rosa']),
  ];

  final Map<String, String> imagenesProductos = {
    '1': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500',
    '2': 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=500',
    '3': 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=500',
    '4': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500',
    '5': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500',
  };

  final Color colorFondo = const Color(0xFFF7F4F0);
  final Color colorRosaOscuro = const Color(0xFFD81B60);

  // Método para mostrar el BottomSheet del FAB
  void _mostrarFormularioNuevo(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo Producto - Variedades Genali',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: colorRosaOscuro),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            listaProductos.add(
                              Producto(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                nombre: nombreController.text,
                                categoria: _categoriaSeleccionada ?? 'Dama',
                                precio: double.parse(precioController.text),
                                descripcion: descController.text,
                                tallas: ['S', 'M', 'L'],
                                colores: ['Rosa'],
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Producto agregado exitosamente')),
                          );
                        }
                      },
                      child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Diseño Responsive basado en el ancho de la pantalla (MediaQuery)
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columnas en tablets, 2 en celulares

    // Filtrado de productos por categoría y barra de búsqueda
    final productosAMostrar = listaProductos.where((p) {
      final coincideCategoria = _categoriaSeleccionada == null || _categoriaSeleccionada == 'Todos' || p.categoria == _categoriaSeleccionada;
      final coincideBusqueda = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();

    final categoriasDisponibles = ['Todos', 'Dama', 'Ropa Casual', 'Ropa Elegante'];

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorRosaOscuro),
        title: Text(
          _categoriaSeleccionada ?? 'Catálogo Genali Shop',
          style: TextStyle(color: colorRosaOscuro, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorRosaOscuro,
        onPressed: () => _mostrarFormularioNuevo(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtroBusqueda = value),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search, color: colorRosaOscuro),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Mecanismo de Filtro con ChoiceChip 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: categoriasDisponibles.map((cat) {
                final seleccionado = _categoriaSeleccionada == cat || (cat == 'Todos' && _categoriaSeleccionada == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: seleccionado,
                    selectedColor: colorRosaOscuro.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: seleccionado ? colorRosaOscuro : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _categoriaSeleccionada = cat == 'Todos' ? null : cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Listado en GridView.builder con diseño Responsive
          Expanded(
            child: productosAMostrar.isEmpty
                ? const Center(child: Text('No se encontraron productos'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.70, // Proporción de tarjeta (ancho/alto)
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productosAMostrar.length,
                    itemBuilder: (context, index) {
                      final producto = productosAMostrar[index];
                      final urlImagen = imagenesProductos[producto.id] ?? 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500';
                      final esFavorito = _favoritosIds.contains(producto.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(producto: producto)),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagen y Botón de Favorito encimado
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      urlImagen,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                                        height: 120,
                                        child: Center(child: Icon(Icons.image, size: 50)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: IconButton(
                                      icon: Icon(
                                        esFavorito ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (esFavorito) {
                                            _favoritosIds.remove(producto.id);
                                          } else {
                                            _favoritosIds.add(producto.id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Información del producto dentro de la tarjeta
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'L. ${producto.precio.toStringAsFixed(2)}',
                                      style: TextStyle(color: colorRosaOscuro, fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                  ],
                                ),
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