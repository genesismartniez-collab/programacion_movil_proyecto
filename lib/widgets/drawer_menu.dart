import 'package:flutter/material.dart';
import '../models/sesion.dart';

class DrawerMenu extends StatelessWidget {
  final String rolUsuario;
  final String correoUsuario;

  const DrawerMenu({
    super.key,
    required this.rolUsuario,
    required this.correoUsuario,
  });

  static const Color _rosa = Color(0xFFFFADCD);
  static const Color _rosa2 = Color(0xFFFFC4DD);
  static const Color _rosaSuave = Color(0xFFFDECF4);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  @override
  Widget build(BuildContext context) {
    final bool esGerente = rolUsuario.toLowerCase() == 'gerente';
    final String nombre = Sesion.nombre.isNotEmpty
        ? Sesion.nombre
        : (esGerente ? 'Gerente General' : 'Empleada Genali');
    final String correo = correoUsuario.isNotEmpty ? correoUsuario : Sesion.correo;
    final String inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(nombre, correo, inicial, esGerente),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              children: [
                _item(context, Icons.storefront, 'Catálogo de Productos', () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, esGerente ? '/home_gerente' : '/catalogo');
                }, destacado: true),
                _item(context, Icons.receipt_long, 'Registro de Ventas', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ventas_empleados');
                }),
                _item(context, Icons.favorite, 'Favoritos / Lo más vendido', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/favoritos');
                }),
                _item(context, Icons.person, 'Perfil de Usuario', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/perfil');
                }),
                if (esGerente) ...[
                  _seccion('PANEL DE GERENCIA'),
                  _item(context, Icons.add_box, 'Agregar Nuevo Producto', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/agregar_producto');
                  }),
                  _item(context, Icons.person_add, 'Crear Nuevo Empleado', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/gestion_usuarios');
                  }),
                  _item(context, Icons.bar_chart, 'Reportes y Estadísticas', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reportes');
                  }),
                  _item(context, Icons.settings, 'Ajustes del Sistema', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ajustes del sistema: próximamente')),
                    );
                  }),
                ],
                const SizedBox(height: 10),
                _cerrarSesion(context),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(String nombre, String correo, String inicial, bool esGerente) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rosa, _rosa2],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(inicial, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _rosa)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hola,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(correo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(esGerente ? Icons.verified_user : Icons.badge, color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Text(esGerente ? 'Administrador' : 'Empleado/a',
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Item de menú ----------
  Widget _item(BuildContext context, IconData icono, String texto, VoidCallback onTap, {bool destacado = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: destacado ? _rosaSuave : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: destacado ? Border.all(color: _rosa.withValues(alpha: 0.4)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: _rosaSuave, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icono, color: _rosa, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(texto,
                      style: const TextStyle(color: _textoOscuro, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right, color: _textoGris),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 6),
      child: Row(
        children: [
          Text(titulo, style: const TextStyle(color: _textoGris, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: const Color(0xFFECEFF2))),
        ],
      ),
    );
  }

  Widget _cerrarSesion(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _rosaSuave, borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            Sesion.limpiar();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('Cerrar Sesión',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.chevron_right, color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Footer ----------
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      decoration: const BoxDecoration(
        color: _rosaSuave,
        borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Genali', style: TextStyle(color: _rosa, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Gestión de Productos', style: TextStyle(color: _textoGris, fontSize: 12)),
              ],
            ),
          ),
          const Text('v1.0.0', style: TextStyle(color: _textoGris, fontSize: 12)),
        ],
      ),
    );
  }
}
