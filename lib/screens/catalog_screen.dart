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
                // Campo 1: Nombre
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 10),
                // Campo 2: Precio
                TextFormField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                ),
                const SizedBox(height: 10),
                // Campo 3: Descripción
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
                                categoria: widget.categoriaFiltro ?? 'Dama',
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
          widget.categoriaFiltro ?? 'Catálogo Genali Shop',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtroBusqueda = value),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search, color: colorRosaOscuro),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          Expanded(
            child: productosAMostrar.isEmpty
                ? const Center(child: Text('No se encontraron productos'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productosAMostrar.length,
                    itemBuilder: (context, index) {
                      final producto = productosAMostrar[index];
                      final urlImagen = imagenesProductos[producto.id] ?? 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500';
                      final esFavorito = _favoritosIds.contains(producto.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Dismissible(
                          key: Key(producto.id),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.delete, color: Colors.white),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: Text('¿Desea eliminar "${producto.nombre}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Acción de Edición activada para: ${producto.nombre}')),
                              );
                              return false;
                            }
                          },
                          onDismissed: (direction) {
                            setState(() {
                              listaProductos.removeWhere((p) => p.id == producto.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item eliminado correctamente mediante Dismissible')),
                            );
                          },
                          child: Stack(
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('¿Desea eliminar este item?'),
                                      content: Text('Se eliminará ${producto.nombre} del sistema.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              listaProductos.removeWhere((p) => p.id == producto.id);
                                            });
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Item eliminado por longPress')),
                                            );
                                          },
                                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        urlImagen,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
                                      ),
                                    ),
                                    title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('L. ${producto.precio.toStringAsFixed(2)}'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ProductDetailScreen(producto: producto)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
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