import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'admin_login_screen.dart';
import 'login_screen.dart';
import '../widgets/mi_item_card.dart';
import '../widgets/mi_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _mostrarFormularioBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final categoriaController = TextEditingController();
    final precioController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ Registrar Nuevo Producto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del producto', prefixIcon: Icon(Icons.shopping_bag, color: Colors.pinkAccent), border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category, color: Colors.pinkAccent), border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese la categoría' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio', prefixIcon: Icon(Icons.attach_money, color: Colors.pinkAccent), border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el precio' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade400)),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('¡Producto registrado con éxito!'),
                                action: SnackBarAction(
                                  label: 'VER CATÁLOGO',
                                  textColor: Colors.amberAccent,
                                  onPressed: () => setState(() => _selectedIndex = 1),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    final Color colorRosaOscuro = Colors.pinkAccent;
    final Color colorDorado = const Color(0xFFC5A059);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFFFC0CB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MiStatusWidget(
                estado: 'activo',
                tituloResumen: 'Estado Operativo de Tienda',
                cantidad: 24,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  '✨ NEW COLLECTION ✨',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.pinkAccent, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 45, color: Colors.pinkAccent),
              ),
              const SizedBox(height: 20),
              const Text('Bienvenida', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              const Text('Explora nuestra exclusiva colección de productos con la mejor calidad.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
              const SizedBox(height: 30),
              MiItemCard(
                titulo: 'Crocs Edición Especial',
                subtitulo: 'Calzado cómodo y en tendencia',
                precio: 850.00,
                categoria: 'Calzado',
                mostrarBadge: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccionaste Crocs Edición Especial'))),
                onAccionSecundaria: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Acción rápida ejecutada'))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('VER CATÁLOGO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.pinkAccent, backgroundColor: Colors.white.withOpacity(0.5), minimumSize: const Size(double.infinity, 50), side: const BorderSide(color: Colors.pinkAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                onPressed: () => setState(() => _selectedIndex = 3),
                icon: const Icon(Icons.person_outline),
                label: const Text('VER PERFIL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 15),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.black87, minimumSize: const Size(double.infinity, 45)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen())),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.pinkAccent),
                label: const Text('Acceso de Empleados', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 25),
              const Align(alignment: Alignment.centerLeft, child: Text('✨ Ofertas y Cupones VIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87))),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF383838)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colorDorado.withOpacity(0.6), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: colorDorado, borderRadius: BorderRadius.circular(20)), child: const Text('CUPÓN ACTIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1))),
                        Icon(Icons.local_offer_rounded, color: colorDorado, size: 26),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('¡20% OFF en toda la tienda!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 4),
                    const Text('Usa el código al realizar tus compras o reclámalo aquí.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: colorRosaOscuro, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cupón copiado!'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.pinkAccent)),
                        child: const Text('COPIAR CÓDIGO: GENALI20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F5),
        elevation: 0,
        title: const Text('Variedades Genali', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28), onPressed: () => Scaffold.of(context).openDrawer())),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.pinkAccent, Colors.deepOrangeAccent], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [CircleAvatar(backgroundColor: Colors.white, radius: 28, child: Text("VG", style: TextStyle(fontSize: 22, color: Colors.pinkAccent, fontWeight: FontWeight.bold))), SizedBox(height: 10), Text('Variedades Genali', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
            ),
            ListTile(leading: const Icon(Icons.home_rounded, color: Colors.pinkAccent), title: const Text('Inicio'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 0); }),
            ListTile(leading: const Icon(Icons.shopping_bag_rounded, color: Colors.pinkAccent), title: const Text('Ver Catálogo'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 1); }),
            ListTile(leading: const Icon(Icons.person_rounded, color: Colors.pinkAccent), title: const Text('Mi Perfil'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 3); }),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const CatalogScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.pinkAccent),
        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _mostrarFormularioBottomSheet(context),
      ),
    );
  }
}