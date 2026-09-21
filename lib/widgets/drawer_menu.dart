import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final String rolUsuario;
  final String correoUsuario;

  const DrawerMenu({
    super.key,
    required this.rolUsuario,
    required this.correoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    bool esGerente = rolUsuario.toLowerCase() == 'gerente';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              esGerente ? 'Gerente General 👑' : 'Empleada Genali ✨',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(correoUsuario),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                correoUsuario.isNotEmpty ? correoUsuario[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.pinkAccent,
            ),
          ),
          
          // Opciones comunes para todos
          ListTile(
            leading: const Icon(Icons.store, color: Colors.pinkAccent),
            title: const Text('Catálogo de Productos'),
            onTap: () {
              Navigator.pop(context);
              if (esGerente) {
                Navigator.pushReplacementNamed(context, '/home_gerente');
              } else {
                Navigator.pushReplacementNamed(context, '/catalogo');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.pinkAccent),
            title: const Text('Registro de Ventas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ventas_empleados');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
            title: const Text('Favoritos / Lo más vendido'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favoritos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.pinkAccent),
            title: const Text('Perfil de Usuario'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/perfil');
            },
          ),

          // ==========================================
          // SECCIÓN EXCLUSIVA PARA EL GERENTE
          // ==========================================
          if (esGerente) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'PANEL DE GERENCIA',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.pink),
              title: const Text('Agregar Nuevo Producto'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agregar_producto');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.pink),
              title: const Text('Crear Nuevo Empleado'), // <--- BOTÓN EXCLUSIVO
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gestion_usuarios');
              },
            ),
          ],

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              // Limpia la pila y regresa al Login correctamente
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}