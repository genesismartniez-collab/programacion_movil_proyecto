import 'package:flutter/material.dart';
import '../models/sesion.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _rosa = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: _textoGris)),
          ),
          TextButton(
            onPressed: () {
              Sesion.limpiar();
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Salir', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = Sesion.nombre.isNotEmpty ? Sesion.nombre : 'Usuario';
    final correo = Sesion.correo.isNotEmpty ? Sesion.correo : 'sin-correo';
    final rol = Sesion.esGerente ? 'Gerente' : 'Empleado/a';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildEncabezado(context, nombre, correo, rol, inicial),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  _buildTarjetaDato(Icons.person_outline, 'Nombre', nombre),
                  const SizedBox(height: 12),
                  _buildTarjetaDato(Icons.mail_outline, 'Correo', correo),
                  const SizedBox(height: 12),
                  _buildTarjetaDato(
                    Sesion.esGerente ? Icons.workspace_premium_outlined : Icons.badge_outlined,
                    'Rol',
                    rol,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _cerrarSesion(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Variedades Genali · v1.0', style: TextStyle(color: _textoGris, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context, String nombre, String correo, String rol, String inicial) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 52, 16, 28),
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Perfil de Usuario',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 46,
            backgroundColor: Colors.white,
            child: Text(inicial, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _rosa)),
          ),
          const SizedBox(height: 12),
          Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: Text(rol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaDato(IconData icono, String etiqueta, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: _rosa),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: const TextStyle(color: _textoGris, fontSize: 13)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(color: _textoOscuro, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
