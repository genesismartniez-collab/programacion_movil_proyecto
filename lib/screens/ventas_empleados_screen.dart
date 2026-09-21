import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VentasEmpleadosScreen extends StatefulWidget {
  const VentasEmpleadosScreen({super.key});

  @override
  State<VentasEmpleadosScreen> createState() => _VentasEmpleadosScreenState();
}

class _VentasEmpleadosScreenState extends State<VentasEmpleadosScreen> {
  final String baseUrl = 'http://localhost:3000';

  bool _cargandoDatos = true;
  bool _registrando = false;

  List<Map<String, dynamic>> _empleados = [];
  List<Map<String, dynamic>> _productos = [];

  String? _empleadoSel;
  int? _productoIdSel;
  String? _tallaSel;
  int _cantidad = 1;

  static const Color _rosaFuerte = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargandoDatos = true);
    try {
      final respUsers = await http.get(Uri.parse('$baseUrl/users')).timeout(const Duration(seconds: 15));
      final respProds = await http.get(Uri.parse('$baseUrl/productos')).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (respUsers.statusCode == 200) {
        final List<dynamic> data = jsonDecode(respUsers.body);
        _empleados = data.map<Map<String, dynamic>>((u) => {
              'nombre': '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim(),
              'correo': u['correo'] ?? '',
            }).toList();
      }
      if (respProds.statusCode == 200) {
        final List<dynamic> data = jsonDecode(respProds.body);
        _productos = data.map<Map<String, dynamic>>((p) => {
              'id': p['id'],
              'nombre': p['nombre'] ?? '',
              'tallas': List<String>.from(p['tallas'] ?? []),
              'stock': p['stock'] ?? 0,
            }).toList();
      }
      setState(() => _cargandoDatos = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoDatos = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los datos. ¿Backend encendido?')),
      );
    }
  }

  Map<String, dynamic>? get _productoSel {
    if (_productoIdSel == null) return null;
    try {
      return _productos.firstWhere((p) => p['id'] == _productoIdSel);
    } catch (_) {
      return null;
    }
  }

  Future<void> _registrarVenta() async {
    if (_empleadoSel == null || _productoIdSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona empleado y producto'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    setState(() => _registrando = true);
    try {
      final prod = _productoSel;
      final response = await http.post(
        Uri.parse('$baseUrl/ventas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productoId': _productoIdSel,
          'producto': prod?['nombre'],
          'talla': _tallaSel,
          'cantidad': _cantidad,
          'empleado': _empleadoSel,
        }),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final stock = data['stockRestante'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stock != null
                ? '🔔 ¡Venta registrada! Stock restante: $stock unidades.'
                : '🔔 ¡Venta registrada con éxito!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Refrescar stock y limpiar selección
        setState(() {
          _tallaSel = null;
          _cantidad = 1;
        });
        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor (${response.statusCode})'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _registrando = false);
    }
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
            Expanded(
              child: _cargandoDatos
                  ? const Center(child: CircularProgressIndicator(color: _rosaFuerte))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _buildTarjetaInfo(),
                        const SizedBox(height: 20),
                        const Text('Datos de la venta',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textoOscuro)),
                        const SizedBox(height: 2),
                        const Text('Completa la información para registrar la salida de inventario.',
                            style: TextStyle(color: _textoGris, fontSize: 13)),
                        const SizedBox(height: 16),
                        _buildDropdownEmpleado(),
                        const SizedBox(height: 14),
                        _buildDropdownProducto(),
                        const SizedBox(height: 14),
                        _buildDropdownTalla(),
                        const SizedBox(height: 14),
                        _buildCantidad(),
                        const SizedBox(height: 20),
                        _buildAvisoStock(),
                        const SizedBox(height: 24),
                        _buildBotonRegistrar(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Encabezado ----------
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
                Text('Registro Operativo de Ventas',
                    style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ---------- Tarjeta info superior ----------
  Widget _buildTarjetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFF9D6E7), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, color: _rosaFuerte, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registra una venta y actualiza el inventario automáticamente.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textoOscuro)),
                SizedBox(height: 4),
                Text('Rápido, simple y seguro.', style: TextStyle(color: _textoGris, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Dropdown genérico tipo tarjeta ----------
  Widget _tarjetaDropdown({
    required IconData icono,
    required String label,
    required Widget dropdown,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: _rosaFuerte, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: dropdown),
        ],
      ),
    );
  }

  Widget _buildDropdownEmpleado() {
    return _tarjetaDropdown(
      icono: Icons.person_outline,
      label: 'Empleado',
      dropdown: DropdownButtonFormField<String>(
        initialValue: _empleadoSel,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: _textoGris),
        decoration: const InputDecoration(
          labelText: 'Empleado',
          labelStyle: TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        hint: const Text('Selecciona el empleado', style: TextStyle(color: _textoGris)),
        items: _empleados
            .map((e) => DropdownMenuItem<String>(
                  value: e['correo'],
                  child: Text(
                    e['nombre'].isNotEmpty ? e['nombre'] : e['correo'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (v) => setState(() => _empleadoSel = v),
      ),
    );
  }

  Widget _buildDropdownProducto() {
    return _tarjetaDropdown(
      icono: Icons.shopping_bag_outlined,
      label: 'Producto vendido',
      dropdown: DropdownButtonFormField<int>(
        initialValue: _productoIdSel,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: _textoGris),
        decoration: const InputDecoration(
          labelText: 'Producto vendido',
          labelStyle: TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        hint: const Text('Selecciona un producto', style: TextStyle(color: _textoGris)),
        items: _productos
            .map((p) => DropdownMenuItem<int>(
                  value: p['id'],
                  child: Text('${p['nombre']}  (stock: ${p['stock']})', overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (v) => setState(() {
          _productoIdSel = v;
          _tallaSel = null; // reset talla al cambiar producto
        }),
      ),
    );
  }

  Widget _buildDropdownTalla() {
    final tallas = (_productoSel?['tallas'] as List?)?.cast<String>() ?? <String>[];
    return _tarjetaDropdown(
      icono: Icons.straighten,
      label: 'Talla o atributo',
      dropdown: DropdownButtonFormField<String>(
        initialValue: _tallaSel,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: _textoGris),
        decoration: const InputDecoration(
          labelText: 'Talla o atributo',
          labelStyle: TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        hint: Text(
          _productoIdSel == null ? 'Primero elige un producto' : 'Selecciona la talla o atributo',
          style: const TextStyle(color: _textoGris),
        ),
        items: tallas
            .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
            .toList(),
        onChanged: tallas.isEmpty ? null : (v) => setState(() => _tallaSel = v),
      ),
    );
  }

  // ---------- Cantidad con - / + ----------
  Widget _buildCantidad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.format_list_numbered, color: _rosaFuerte, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Cantidad vendida',
                style: TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          _botonCantidad(Icons.remove, () {
            if (_cantidad > 1) setState(() => _cantidad--);
          }),
          Container(
            width: 54,
            alignment: Alignment.center,
            child: Text('$_cantidad',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textoOscuro)),
          ),
          _botonCantidad(Icons.add, () => setState(() => _cantidad++)),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(12)),
        child: Icon(icono, color: _rosaFuerte, size: 22),
      ),
    );
  }

  // ---------- Aviso stock ----------
  Widget _buildAvisoStock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFF9D6E7), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, color: _rosaFuerte, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('El stock se actualizará automáticamente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textoOscuro)),
                SizedBox(height: 4),
                Text('y recibirás una notificación si el inventario queda en un nivel bajo.',
                    style: TextStyle(color: _textoGris, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Botón registrar ----------
  Widget _buildBotonRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _rosaFuerte,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _rosaFuerte.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _registrando ? null : _registrarVenta,
        child: _registrando
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 22),
                  SizedBox(width: 10),
                  Flexible(child: Text('Registrar Venta y Notificar Stock',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }
}
