import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final String baseUrl = 'http://localhost:3000';
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _favoritos = [];

  static const Color _rosa = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos')).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _favoritos = data
              .where((p) => p['esFavorito'] == true)
              .map<Map<String, dynamic>>((p) => {
                    'nombre': p['nombre'] ?? '',
                    'categoria': p['categoria'] ?? '',
                    'stock': p['stock'] ?? 0,
                    'precio': (p['precio'] ?? 0).toDouble(),
                    'imagen': p['imagen'],
                  })
              .toList();
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
        _error = 'No se pudo conectar con el servidor.';
        _cargando = false;
      });
    }
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
                Text('Lo más vendido',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.star, color: Colors.white, size: 28),
          const SizedBox(width: 8),
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
                onPressed: _cargarFavoritos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (_favoritos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star_border, size: 60, color: _textoGris),
              SizedBox(height: 14),
              Text('Todavía no hay productos destacados.\nMarca un producto como "Lo más vendido" al crearlo.',
                  textAlign: TextAlign.center, style: TextStyle(color: _textoGris)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _rosa,
      onRefresh: _cargarFavoritos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          final prod = _favoritos[index];
          final String? imagen = prod['imagen'];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: (imagen != null && imagen.isNotEmpty)
                        ? Image.network(imagen, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _placeholder(prod['categoria']))
                        : _placeholder(prod['categoria']),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(prod['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textoOscuro)),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(prod['categoria'], style: const TextStyle(color: _textoGris, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Stock: ${prod['stock']}  ·  L. ${(prod['precio'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(color: _rosa, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(String categoria) {
    return Container(
      color: const Color(0xFFFDECF4),
      alignment: Alignment.center,
      child: Icon(_iconoPorCategoria(categoria), color: _rosa, size: 30),
    );
  }
}
