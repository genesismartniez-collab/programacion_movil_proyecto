import 'package:flutter/material.dart';
import 'models/producto.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/api_test_screen.dart'; // <--- Importación de la pantalla de prueba de API

// Punto de entrada de la aplicación; aquí arranca todo ejecutando el widget principal.
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Quitamos la etiqueta de "debug" de la esquina superior derecha
      debugShowCheckedModeBanner: false,
      title: 'Variedades Genali',
      // Configuramos el tema general usando Material 3 y un color base rosado
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      // Definimos que la app abra primero la pantalla de prueba de la API
      initialRoute: '/api_test',
      // Mapa con todas las rutas disponibles en la aplicación
      routes: {
        '/api_test': (context) => const ApiTestScreen(), // <--- Ruta agregada
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainWrapper(), // Contenedor principal con barra de navegación
        '/catalogo': (context) => const CatalogScreen(),
        '/carrito': (context) => const CartScreen(),
        '/perfil': (context) => const ProfileScreen(),
        // Ruta para el detalle del producto, recibe el objeto 'Producto' como argumento
        '/detalle': (context) => ProductDetailScreen(
              producto: ModalRoute.of(context)!.settings.arguments as Producto,
            ),
      },
    );
  }
}

// Widget con estado para manejar la barra de navegación inferior (BottomNavigationBar)
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Índice actual para saber qué pestaña está seleccionada (comienza en Inicio)
  int _currentIndex = 0;

  // Lista de pantallas principales a las que se puede acceder desde el menú inferior
  final List<Widget> _screens = [
    const HomeScreen(),
    const CatalogScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos IndexedStack para mantener el estado de cada pantalla al cambiar de pestaña
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Barra de navegación inferior con sus respectivos íconos y etiquetas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent, // Color resaltado para la pestaña activa
        unselectedItemColor: Colors.grey,    // Color para las pestañas inactivas
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}