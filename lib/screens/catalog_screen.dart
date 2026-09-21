import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/notificacion_stock.dart';
import 'agregar_producto_screen.dart';

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
  String _busqueda = '';
  bool _ordenarMasVendidos = true;
  int _indiceNav = 0;

  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _productos = [];

  final String baseUrl = 'http://localhost:3000';

  static const Color _rosaFuerte = Color(0xFFFFADCD);
  static const Color _rosaClaro = Color(0xFFFF6FB0);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);
  static const Color _verde = Color(0xFF22B573);

  // Categorías con su ícono para los chips superiores.
  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Todos', 'icono': Icons.grid_view_rounded},
    {'nombre': 'Calzado', 'icono': Icons.ice_skating_outlined},
    {'nombre': 'Accesorios', 'icono': Icons.shopping_bag_outlined},
    {'nombre': 'Vestido Dama', 'icono': Icons.checkroom_outlined},
    {'nombre': 'Fútbol', 'icono': Icons.sports_soccer},
    {'nombre': 'Perfumería', 'icono': Icons.spa_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _inicializarOneSignal();
    _cargarProductos();
  }

  void _inicializarOneSignal() {
    OneSignal.initialize("fd143feb-5d7e-4f4e-8494-e7016ca7935b");
    // Nota: no se pide permiso de notificaciones al abrir el catálogo.
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/productos'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _productos = data.map<Map<String, dynamic>>((p) {
            return {
              'id': p['id'],
              'nombre': p['nombre'] ?? '',
              'categoria': p['categoria'] ?? '',
              'precio': (p['precio'] ?? 0).toDouble(),
              'stock': p['stock'] ?? 0,
              'tallas': List<String>.from(p['tallas'] ?? []),
              'imagen': p['imagen'],
              'esFavorito': p['esFavorito'] ?? false,
              'descripcion': p['descripcion'] ?? '',
              'activo': p['activo'] ?? true,
            };
          }).toList();
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'El servidor respondió ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con el servidor.\n¿Está corriendo el backend?';
        _cargando = false;
      });
    }
  }

  Future<void> _abrirAgregarProducto() async {
    final resultado = await Navigator.pushNamed(context, '/agregar_producto');
    if (resultado != null) _cargarProductos();
  }

  Future<void> _editarProducto(Map<String, dynamic> producto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgregarProductoScreen(producto: producto)),
    );
    if (resultado != null) _cargarProductos();
  }

  Future<void> _eliminarProducto(Map<String, dynamic> producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres eliminar "${producto['nombre']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/productos/${producto['id']}'))
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado'), backgroundColor: _rosaFuerte),
        );
        _cargarProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar (${response.statusCode})'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _venderTalla(Map<String, dynamic> producto, String talla) async {
    // Actualización optimista en pantalla
    setState(() {
      (producto['tallas'] as List).remove(talla);
      if (producto['stock'] > 0) producto['stock']--;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Venta registrada! Talla $talla descontada del inventario.'),
        backgroundColor: _rosaFuerte,
        duration: const Duration(seconds: 2),
      ),
    );

    // Notificación de stock bajo (si aplica)
    mostrarAlertaStockBajo(context, producto['nombre']?.toString() ?? 'Producto', producto['stock'] as int);

    // Registrar la venta en el backend (descuenta stock real)
    try {
      await http.post(
        Uri.parse('$baseUrl/ventas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productoId': producto['id'],
          'producto': producto['nombre'],
          'talla': talla,
          'cantidad': 1,
          'empleado': widget.correoUsuario,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Si falla la red, la venta queda reflejada localmente en la vista.
    }
  }

  List<Map<String, dynamic>> get _productosFiltrados {
    var lista = _productos.where((p) {
      final coincideCategoria = _categoriaSeleccionada == 'Todos' || p['categoria'] == _categoriaSeleccionada;
      final coincideBusqueda = _busqueda.isEmpty ||
          p['nombre'].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
          p['categoria'].toString().toLowerCase().contains(_busqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();

    if (_ordenarMasVendidos) {
      lista.sort((a, b) => (b['esFavorito'] ? 1 : 0).compareTo(a['esFavorito'] ? 1 : 0));
    }
    return lista;
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'calzado':
        return Icons.ice_skating_outlined;
      case 'accesorios':
        return Icons.shopping_bag_outlined;
      case 'vestido dama':
        return Icons.checkroom;
      case 'fútbol':
      case 'futbol':
        return Icons.sports_soccer;
      case 'perfumería':
      case 'perfumeria':
        return Icons.spa_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esGerente = widget.rolUsuario.toLowerCase() == 'gerente';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: DrawerMenu(correoUsuario: widget.correoUsuario, rolUsuario: widget.rolUsuario),
      floatingActionButton: esGerente
          ? FloatingActionButton.extended(
              backgroundColor: _rosaFuerte,
              foregroundColor: Colors.white,
              onPressed: _abrirAgregarProducto,
              icon: const Icon(Icons.add),
              label: const Text('Producto'),
            )
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(child: _buildCuerpo()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: _rosaFuerte));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: _textoGris),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _textoGris)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _rosaFuerte, foregroundColor: Colors.white),
                onPressed: _cargarProductos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _rosaFuerte,
      onRefresh: _cargarProductos,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildBuscador(),
          const SizedBox(height: 16),
          _buildCategorias(),
          const SizedBox(height: 20),
          _buildTituloProductos(),
          const SizedBox(height: 12),
          ..._productosFiltrados.map(_buildTarjetaProducto),
          if (_productosFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No hay productos todavía.\nAgrega el primero con el botón +',
                    textAlign: TextAlign.center, style: TextStyle(color: _textoGris)),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Encabezado rosa ----------
  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFADCD), Color(0xFFFFC4DD)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Builder(
        builder: (context) => Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catálogo y Stock',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
              onPressed: _cargarProductos,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Buscador (sin escanear) ----------
  Widget _buildBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _busqueda = v),
        style: const TextStyle(color: _textoOscuro),
        decoration: const InputDecoration(
          hintText: 'Buscar producto, categoría o código...',
          hintStyle: TextStyle(color: _textoGris, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: _textoGris),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
      ),
    );
  }

  // ---------- Chips de categoría ----------
  Widget _buildCategorias() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categorias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          final seleccionada = _categoriaSeleccionada == cat['nombre'];
          return GestureDetector(
            onTap: () => setState(() => _categoriaSeleccionada = cat['nombre']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: seleccionada ? _rosaFuerte : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Icon(cat['icono'], size: 20, color: seleccionada ? Colors.white : _textoGris),
                  const SizedBox(width: 8),
                  Text(
                    cat['nombre'],
                    style: TextStyle(
                      color: seleccionada ? Colors.white : _textoOscuro,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- Título "Productos" + orden ----------
  Widget _buildTituloProductos() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Productos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textoOscuro)),
              SizedBox(height: 2),
              Text('Gestiona tu inventario, tallas y precios.', style: TextStyle(color: _textoGris, fontSize: 13)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _ordenarMasVendidos = !_ordenarMasVendidos),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Text(_ordenarMasVendidos ? 'Más vendidos' : 'Todos',
                    style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600, fontSize: 13)),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: _textoOscuro),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.tune, size: 20, color: _textoOscuro),
        ),
      ],
    );
  }

  // ---------- Tarjeta de producto ----------
  Widget _buildTarjetaProducto(Map<String, dynamic> producto) {
    final List<String> tallas = List<String>.from(producto['tallas']);
    final bool esFavorito = producto['esFavorito'];
    final int stock = producto['stock'];
    final bool hayStock = stock > 0 && tallas.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagenProducto(producto),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            producto['nombre'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _textoOscuro, height: 1.2),
                          ),
                        ),
                        if (widget.rolUsuario.toLowerCase() == 'gerente')
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: _textoGris, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'editar') _editarProducto(producto);
                              if (value == 'eliminar') _eliminarProducto(producto);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'editar',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, color: _rosaFuerte, size: 20),
                                  SizedBox(width: 10),
                                  Text('Editar'),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Row(children: [
                                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 10),
                                  Text('Eliminar'),
                                ]),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(producto['categoria'], style: const TextStyle(color: _textoGris, fontSize: 14)),
                    if (esFavorito) ...[
                      const SizedBox(height: 6),
                      _buildBadgeMasVendido(),
                    ],
                    if ((producto['precio'] ?? 0) > 0) ...[
                      const SizedBox(height: 4),
                      Text('L. ${(producto['precio'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(color: _rosaFuerte, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 9, height: 9,
                          decoration: BoxDecoration(
                            color: hayStock ? _verde : Colors.redAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hayStock ? 'En stock' : 'Agotado',
                          style: TextStyle(
                            color: hayStock ? _verde : Colors.redAccent,
                            fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        Text('$stock unidades',
                            style: const TextStyle(color: _textoOscuro, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFEDEFF2)),
          const Text('Tallas disponibles:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textoOscuro)),
          const SizedBox(height: 10),
          tallas.isEmpty
              ? const Text('¡Agotado en todas las tallas!',
                  style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))
              : Wrap(
                  spacing: 10, runSpacing: 10,
                  children: tallas.map((talla) {
                    return GestureDetector(
                      onTap: () => _venderTalla(producto, talla),
                      child: Container(
                        width: 54, height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(talla,
                            style: const TextStyle(color: _rosaFuerte, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildImagenProducto(Map<String, dynamic> producto) {
    final String? imagen = producto['imagen'];
    final bool esFavorito = producto['esFavorito'];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 90,
            height: 110,
            child: (imagen != null && imagen.isNotEmpty)
                ? Image.network(
                    imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderIcono(producto['categoria']),
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : _placeholderIcono(producto['categoria']),
                  )
                : _placeholderIcono(producto['categoria']),
          ),
        ),
        if (esFavorito)
          Positioned(
            left: 8, top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, size: 14, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _placeholderIcono(String categoria) {
    return Container(
      color: const Color(0xFFFDECF4),
      alignment: Alignment.center,
      child: Icon(_iconoPorCategoria(categoria), size: 44, color: _rosaClaro),
    );
  }

  Widget _buildBadgeMasVendido() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFFFF3D1), borderRadius: BorderRadius.circular(10)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 13, color: Colors.amber),
          SizedBox(width: 4),
          Text('Lo más vendido', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8A6D00))),
        ],
      ),
    );
  }

  // ---------- Barra inferior ----------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _indiceNav,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _rosaFuerte,
        unselectedItemColor: _textoGris,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _indiceNav = index);
    switch (index) {
      case 0:
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/ventas_empleados');
        break;
      case 3:
        Navigator.pushNamed(context, '/reportes');
        break;
      case 4:
        Navigator.pushNamed(context, '/perfil');
        break;
    }
  }
}
