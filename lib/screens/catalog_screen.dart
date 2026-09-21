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
  String _busqueda = '';
  bool _ordenarMasVendidos = true;
  int _indiceNav = 0;

  static const Color _rosaFuerte = Color(0xFFF0338D);
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

  final List<Map<String, dynamic>> _productos = [
    {
      'nombre': 'Camiseta Oficial Selección',
      'categoria': 'Fútbol',
      'icono': Icons.sports_soccer,
      'tallas': ['S', 'M', 'L', 'XL'],
      'stock': 120,
      'esFavorito': true,
    },
    {
      'nombre': 'Tenis Deportivos Urbanos',
      'categoria': 'Calzado',
      'icono': Icons.ice_skating_outlined,
      'tallas': ['38', '39', '40', '41', '42'],
      'stock': 85,
      'esFavorito': true,
    },
    {
      'nombre': 'Vestido Casual Rosado',
      'categoria': 'Vestido Dama',
      'icono': Icons.checkroom,
      'tallas': ['XS', 'S', 'M', 'L'],
      'stock': 60,
      'esFavorito': false,
    },
    {
      'nombre': 'Gorra New York',
      'categoria': 'Accesorios',
      'icono': Icons.shopping_bag_outlined,
      'tallas': ['Única'],
      'stock': 45,
      'esFavorito': false,
    },
    {
      'nombre': 'Perfume Floral Elegante',
      'categoria': 'Perfumería',
      'icono': Icons.spa_outlined,
      'tallas': ['50ml', '100ml'],
      'stock': 30,
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
    // Nota: no se pide permiso de notificaciones al abrir el catálogo
    // para no interrumpir con el popup del sistema.
  }

  void _venderTalla(int indexProducto, String talla) {
    setState(() {
      _productos[indexProducto]['tallas'].remove(talla);
      if (_productos[indexProducto]['stock'] > 0) {
        _productos[indexProducto]['stock']--;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 ¡Venta registrada! Talla $talla descontada del inventario.'),
        backgroundColor: _rosaFuerte,
        duration: const Duration(seconds: 3),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: DrawerMenu(correoUsuario: widget.correoUsuario, rolUsuario: widget.rolUsuario),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(
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
                        child: Text('No hay productos en esta categoría.',
                            style: TextStyle(color: _textoGris)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          colors: [_rosaFuerte, _rosaClaro],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Catálogo y Stock',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Variedades Genali',
                      style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            Stack(
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 30),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: _rosaFuerte, width: 1.5),
                    ),
                  ),
                ),
              ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Productos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textoOscuro)),
              SizedBox(height: 2),
              Text('Gestiona tu inventario, tallas y precios.',
                  style: TextStyle(color: _textoGris, fontSize: 13)),
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
    final realIndex = _productos.indexOf(producto);
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
              _buildImagenProducto(producto['icono'], esFavorito),
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
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _textoOscuro),
                          ),
                        ),
                        if (esFavorito) _buildBadgeMasVendido(),
                        const Icon(Icons.chevron_right, color: _textoGris),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(producto['categoria'], style: const TextStyle(color: _textoGris, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: hayStock ? _verde : Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hayStock ? 'En stock' : 'Agotado',
                          style: TextStyle(
                            color: hayStock ? _verde : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
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
                  spacing: 10,
                  runSpacing: 10,
                  children: tallas.map((talla) {
                    return GestureDetector(
                      onTap: () => _venderTalla(realIndex, talla),
                      child: Container(
                        width: 54,
                        height: 44,
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

  Widget _buildImagenProducto(IconData icono, bool esFavorito) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFDECF4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icono, size: 44, color: _rosaClaro),
        ),
        if (esFavorito)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, size: 14, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeMasVendido() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
        // Inicio / Inventario: ya estamos en el catálogo.
        break;
      case 2:
        Navigator.pushNamed(context, '/ventas_empleados');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reportes: próximamente 📊')),
        );
        break;
      case 4:
        Navigator.pushNamed(context, '/perfil');
        break;
    }
  }
}
