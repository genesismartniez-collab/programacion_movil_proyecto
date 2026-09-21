import 'package:flutter/material.dart';

import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';
import 'screens/agregar_producto_screen.dart';
import 'screens/ventas_empleados_screen.dart';
import 'screens/gestion_usuarios_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/promos_screen.dart';

void main() {
  runApp(const VariedadesGenaliApp());
}

class VariedadesGenaliApp extends StatelessWidget {
  const VariedadesGenaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Variedades Genali',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFF9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
        ),
      ),
      // Cambiamos home para que inicie en el LoginScreen
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home_gerente': (context) => const CatalogScreen(
              rolUsuario: 'gerente',
              correoUsuario: 'genesismartniez@gmail.com',
            ),
        '/catalogo': (context) => const CatalogScreen(
              rolUsuario: 'empleado',
              correoUsuario: 'empleado@genali.com',
            ),
        '/ventas': (context) => const PromosScreen(),
        '/perfil': (context) => const ProfileScreen(),
        '/favoritos': (context) => const FavoritosScreen(),
        '/agregar_producto': (context) => const AgregarProductoScreen(),
        '/ventas_empleados': (context) => const VentasEmpleadosScreen(),
        '/gestion_usuarios': (context) => const GestionUsuariosScreen(),
      },
    );
  }
}