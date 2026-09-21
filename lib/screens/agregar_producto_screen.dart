import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  
  bool _cargando = false;
  // URL de tu backend conectando al puerto 3000 del emulador Android
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<void> _guardarEnMySQL() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        // Estructura de datos que espera tu backend para insertar en MySQL
        final bodyData = {
          'nombre': _nombreController.text.trim(),
          'categoria': _categoriaController.text.trim(),
          'precio': double.tryParse(_precioController.text) ?? 0.0,
          'stock': int.tryParse(_stockController.text) ?? 0,
          'talla': _tallaController.text.trim(),
        };

        // Petición POST real hacia tu servidor Node.js y MySQL
        final response = await http.post(
          Uri.parse('$baseUrl/productos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        ).timeout(const Duration(seconds: 5));

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ¡Producto guardado en MySQL con éxito!'),
              backgroundColor: Colors.pinkAccent,
            ),
          );
          
          // Creamos el objeto para retornarlo también a la lista visual del catálogo
          final nuevoProducto = {
            'id': DateTime.now().millisecondsSinceEpoch,
            'nombre': _nombreController.text.trim(),
            'categoria': _categoriaController.text.trim(),
            'icono': Icons.shopping_bag,
            'tallas': [_tallaController.text.trim()],
            'esFavorito': false,
          };

          Navigator.pop(context, nuevoProducto); // Regresa al catálogo actualizando la vista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Error en el servidor (Código: ${response.statusCode})'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error de conexión con la BD: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _cargando = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar a MySQL (Gerente)'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registro en Base de Datos MySQL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (ej. Calzado, Accesorios)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa la categoría' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio en Lempiras (L.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa el precio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad disponible (Stock)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa el stock' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _tallaController,
                decoration: const InputDecoration(
                  labelText: 'Tallas (ej. S, M, L o Única)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa las tallas' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _cargando ? null : _guardarEnMySQL,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar en MySQL y Catálogo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}