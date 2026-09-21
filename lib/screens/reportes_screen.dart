import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/notificacion_stock.dart' show kStockBajo;

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final String baseUrl = 'http://localhost:3000';

  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _ventas = [];

  static const Color _rosa = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);
  static const Color _verde = Color(0xFF22B573);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final rp = await http.get(Uri.parse('$baseUrl/productos')).timeout(const Duration(seconds: 15));
      final rv = await http.get(Uri.parse('$baseUrl/ventas')).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (rp.statusCode == 200 && rv.statusCode == 200) {
        setState(() {
          _productos = (jsonDecode(rp.body) as List).cast<Map<String, dynamic>>();
          _ventas = (jsonDecode(rv.body) as List).cast<Map<String, dynamic>>();
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'El servidor respondió con un error.';
          _cargando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con el servidor.';
        _cargando = false;
      });
    }
  }

  // ---------- Cálculos ----------
  int get _totalProductos => _productos.length;

  int get _unidadesStock =>
      _productos.fold(0, (s, p) => s + ((p['stock'] ?? 0) as num).toInt());

  double get _valorInventario => _productos.fold(
      0.0, (s, p) => s + ((p['precio'] ?? 0) as num).toDouble() * ((p['stock'] ?? 0) as num).toInt());

  int get _unidadesVendidas =>
      _ventas.fold(0, (s, v) => s + ((v['cantidad'] ?? 0) as num).toInt());

  List<Map<String, dynamic>> get _stockBajo =>
      _productos.where((p) => ((p['stock'] ?? 0) as num).toInt() <= kStockBajo).toList();

  /// Agrupa las ventas por producto (suma de cantidades), ordenado desc.
  List<MapEntry<String, int>> get _topProductos {
    final Map<String, int> mapa = {};
    for (final v in _ventas) {
      final nombre = (v['producto'] ?? 'Desconocido').toString();
      mapa[nombre] = (mapa[nombre] ?? 0) + ((v['cantidad'] ?? 0) as num).toInt();
    }
    final lista = mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return lista.take(5).toList();
  }

  /// Agrupa las ventas por empleado.
  List<MapEntry<String, int>> get _porEmpleado {
    final Map<String, int> mapa = {};
    for (final v in _ventas) {
      final emp = (v['empleado'] ?? 'Sin asignar').toString();
      final nombre = emp.isEmpty ? 'Sin asignar' : emp;
      mapa[nombre] = (mapa[nombre] ?? 0) + ((v['cantidad'] ?? 0) as num).toInt();
    }
    final lista = mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(child: _buildCuerpo()),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 52, 16, 18),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reportes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            onPressed: _cargar,
          ),
        ],
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: _rosa));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: _textoGris),
              const SizedBox(height: 14),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _textoGris)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _rosa, foregroundColor: Colors.white),
                onPressed: _cargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _rosa,
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildKpis(),
          const SizedBox(height: 24),
          _buildSeccion(Icons.emoji_events_outlined, 'Productos más vendidos', _buildTopProductos()),
          const SizedBox(height: 24),
          _buildSeccion(Icons.people_alt_outlined, 'Ventas por empleado', _buildPorEmpleado()),
          const SizedBox(height: 24),
          _buildSeccion(Icons.warning_amber_rounded, 'Productos con stock bajo', _buildStockBajo()),
        ],
      ),
    );
  }

  Widget _buildKpis() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _kpi(Icons.inventory_2_outlined, '$_totalProductos', 'Productos')),
            const SizedBox(width: 12),
            Expanded(child: _kpi(Icons.layers_outlined, '$_unidadesStock', 'Unidades en stock')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _kpi(Icons.attach_money, 'L. ${_valorInventario.toStringAsFixed(0)}', 'Valor inventario')),
            const SizedBox(width: 12),
            Expanded(child: _kpi(Icons.shopping_cart_checkout, '$_unidadesVendidas', 'Unidades vendidas')),
          ],
        ),
      ],
    );
  }

  Widget _kpi(IconData icono, String valor, String etiqueta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(10)),
            child: Icon(icono, color: _rosa, size: 22),
          ),
          const SizedBox(height: 12),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textoOscuro)),
          const SizedBox(height: 2),
          Text(etiqueta, style: const TextStyle(color: _textoGris, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSeccion(IconData icono, String titulo, Widget contenido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: _rosa, size: 20),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textoOscuro)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: contenido,
        ),
      ],
    );
  }

  Widget _buildTopProductos() {
    final top = _topProductos;
    if (top.isEmpty) {
      return const Text('Aún no hay ventas registradas.', style: TextStyle(color: _textoGris));
    }
    final maxVal = top.first.value;
    return Column(
      children: top.map((e) => _barra(e.key, e.value, maxVal, _rosa)).toList(),
    );
  }

  Widget _buildPorEmpleado() {
    final lista = _porEmpleado;
    if (lista.isEmpty) {
      return const Text('Aún no hay ventas registradas.', style: TextStyle(color: _textoGris));
    }
    final maxVal = lista.first.value;
    return Column(
      children: lista.map((e) => _barra(_nombreCorto(e.key), e.value, maxVal, _verde)).toList(),
    );
  }

  String _nombreCorto(String correo) {
    if (correo.contains('@')) return correo.split('@').first;
    return correo;
  }

  /// Barra horizontal proporcional (sin librerías de gráficas).
  Widget _barra(String etiqueta, int valor, int maxVal, Color color) {
    final double factor = maxVal > 0 ? valor / maxVal : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Text('$valor', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F1F4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBajo() {
    final bajo = _stockBajo;
    if (bajo.isEmpty) {
      return Row(
        children: const [
          Icon(Icons.check_circle, color: _verde, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text('Todo el inventario está en buen nivel. ', style: TextStyle(color: _textoGris))),
        ],
      );
    }
    return Column(
      children: bajo.map((p) {
        final stock = ((p['stock'] ?? 0) as num).toInt();
        final agotado = stock <= 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(agotado ? Icons.error_outline : Icons.warning_amber_rounded,
                  color: agotado ? Colors.redAccent : const Color(0xFFB8860B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(p['nombre']?.toString() ?? 'Producto',
                    style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: agotado ? const Color(0xFFFDE2E1) : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(agotado ? 'Agotado' : '$stock uds',
                    style: TextStyle(
                        color: agotado ? Colors.redAccent : const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
