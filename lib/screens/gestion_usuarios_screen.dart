import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/sesion.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String baseUrl = 'http://localhost:3000';
  bool _creando = false;
  bool _cargandoLista = true;
  List<Map<String, dynamic>> _empleados = [];

  static const Color _rosa = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _cargarEmpleados() async {
    setState(() => _cargandoLista = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/users')).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _empleados = data.map<Map<String, dynamic>>((u) => {
                'id': u['id'],
                'nombre': '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim(),
                'correo': u['correo'] ?? '',
              }).toList();
          _cargandoLista = false;
        });
      } else {
        setState(() => _cargandoLista = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoLista = false);
    }
  }

  Future<void> _eliminarEmpleado(Map<String, dynamic> empleado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text('¿Seguro que quieres eliminar a "${empleado['nombre']}"?'),
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
          .delete(Uri.parse('$baseUrl/users/${empleado['id']}'))
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado eliminado'), backgroundColor: _rosa),
        );
        _cargarEmpleados();
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

  Future<void> _crearEmpleado() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _creando = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'correo': _correoController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Empleado/a "${_nombreController.text.trim()}" creado con éxito!'),
            backgroundColor: _rosa,
          ),
        );
        _nombreController.clear();
        _apellidoController.clear();
        _correoController.clear();
        _passwordController.clear();
        _cargarEmpleados(); // refrescar lista
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'No se pudo crear el empleado (${response.statusCode})'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _creando = false);
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _buildTarjetaInfo(),
                  const SizedBox(height: 20),
                  const Text('Crear nueva cuenta de personal',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textoOscuro)),
                  const SizedBox(height: 16),
                  _buildFormulario(),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Empleados registrados',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textoOscuro)),
                      ),
                      IconButton(
                        onPressed: _cargarEmpleados,
                        icon: const Icon(Icons.refresh, color: _rosa),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildListaEmpleados(),
                ],
              ),
            ),
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
                Text('Gestión de Empleados',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.group_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTarjetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person_add_alt_1, color: _rosa),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Da de alta a tu personal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textoOscuro)),
                SizedBox(height: 2),
                Text('Las cuentas se guardan en la base de datos.',
                    style: TextStyle(color: _textoGris, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _campo(_nombreController, 'Nombre', Icons.person_outline, obligatorio: true),
            const SizedBox(height: 14),
            _campo(_apellidoController, 'Apellido', Icons.badge_outlined),
            const SizedBox(height: 14),
            _campo(_correoController, 'Correo electrónico', Icons.mail_outline,
                obligatorio: true, teclado: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _campo(_passwordController, 'Contraseña temporal', Icons.lock_outline,
                obligatorio: true, obscure: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rosa,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _creando ? null : _crearEmpleado,
                child: _creando
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Registrar Empleado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController c, String label, IconData icono,
      {bool obligatorio = false, bool obscure = false, TextInputType? teclado}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: teclado,
      style: const TextStyle(color: _textoOscuro),
      decoration: InputDecoration(
        labelText: obligatorio ? '$label *' : label,
        labelStyle: const TextStyle(color: _textoGris),
        prefixIcon: Icon(icono, color: _rosa),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: obligatorio ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null : null,
    );
  }

  Widget _buildListaEmpleados() {
    if (_cargandoLista) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: _rosa)),
      );
    }
    if (_empleados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Aún no hay empleados registrados.', style: TextStyle(color: _textoGris))),
      );
    }
    return Column(
      children: _empleados.map((e) {
        final nombre = (e['nombre'] as String).isNotEmpty ? e['nombre'] as String : 'Sin nombre';
        final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFDECF4),
                child: Text(inicial, style: const TextStyle(color: _rosa, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: _textoOscuro)),
                    Text(e['correo'], style: const TextStyle(color: _textoGris, fontSize: 13)),
                  ],
                ),
              ),
              if (e['correo'] != Sesion.correo)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _eliminarEmpleado(e),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Tú', style: TextStyle(color: _rosa, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
