import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _estadoConexion = 'Panel de Control y Pruebas - Variedades Genali 🌸';
  bool _cargando = false;
  final String baseUrl = 'http://localhost:3000'; 

  // 1. Probar conexión con el servidor
  Future<void> _probarConexion() async {
    setState(() {
      _cargando = true;
      _estadoConexion = 'Conectando al servidor Node.js...';
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 5));
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _estadoConexion = '¡Conexión exitosa! 🚀\nRespuesta: ${response.body}';
        });
      } else {
        setState(() {
          _estadoConexion = 'El servidor respondió con el código: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estadoConexion = 'Error de conexión:\n$e\n\nAsegúrate de que tu API en Node.js esté corriendo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // 2. Función para Agregar Producto (Rol Gerente)
  Future<void> _probarAgregarProducto() async {
    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/productos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': 'Blusa Rosa Elegant',
          'categoria': 'Vestido Dama',
          'talla': 'M',
          'stock': 15,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje('✅ Producto agregado y guardado en la BD con éxito.');
      } else {
        _mostrarMensaje('⚠️ Error al agregar producto (Código: ${response.statusCode})');
      }
    } catch (e) {
      _mostrarMensaje('❌ Error de red al agregar producto: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // 3. Función para Registrar Venta / Descontar Inventario (Rol Empleado / Gerente)
  Future<void> _probarRegistrarVenta() async {
    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ventas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'producto_id': 1,
          'cantidad': 1,
          'talla': 'M',
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje('💰 ¡Venta registrada y stock descontado en la BD!');
      } else {
        _mostrarMensaje('⚠️ Error al registrar venta (Código: ${response.statusCode})');
      }
    } catch (e) {
      _mostrarMensaje('❌ Error de red al registrar venta: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // 4. Función para Eliminar Producto (Rol Gerente)
  Future<void> _probarEliminarProducto() async {
    setState(() => _cargando = true);
    try {
      // Usamos el ID 1 de ejemplo para eliminar
      final response = await http.delete(
        Uri.parse('$baseUrl/productos/1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        _mostrarMensaje('🗑️ Producto eliminado correctamente de la base de datos.');
      } else {
        _mostrarMensaje('⚠️ No se pudo eliminar (Código: ${response.statusCode})');
      }
    } catch (e) {
      _mostrarMensaje('❌ Error de red al eliminar producto: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.pinkAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel API - Variedades Genali 🌸'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 70, color: Colors.pinkAccent),
              const SizedBox(height: 15),
              Text(
                _estadoConexion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              _cargando
                  ? const CircularProgressIndicator(color: Colors.pinkAccent)
                  : Column(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: _probarConexion,
                          icon: const Icon(Icons.wifi),
                          label: const Text('1. Probar Conexión Servidor'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[400],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: _probarAgregarProducto,
                          icon: const Icon(Icons.add_box),
                          label: const Text('2. Simular Agregar Producto (Gerente)'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[300],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: _probarRegistrarVenta,
                          icon: const Icon(Icons.point_of_sale),
                          label: const Text('3. Simular Venta / Descontar Stock'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: _probarEliminarProducto,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('4. Simular Eliminar Producto (Gerente)'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}