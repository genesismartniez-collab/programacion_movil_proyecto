import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  List<dynamic> _usuarios = [];
  bool _isLoading = true;
  String _error = '';

  // Usamos la IP de tu PC que acabamos de sacar
  final String baseUrl = 'http://192.168.1.5:3000';

  @override
  void initState() {
    super.initState();
    _probarConexion();
  }

  Future<void> _probarConexion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        setState(() {
          _usuarios = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión API'),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.pinkAccent),
                      title: Text(usuario['nombre'] ?? 'Sin nombre'),
                      subtitle: Text(usuario['correo'] ?? 'Sin correo'),
                    );
                  },
                ),
    );
  }
}