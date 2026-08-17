import 'package:flutter/material.dart';
import '../models/producto.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _passController = TextEditingController();
  final String _claveCorrecta = "admin123";
  bool _isLoggedIn = false;
  String _mensajeError = "";

  // Controladores para el formulario fijo de Agregar Producto
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tallasController = TextEditingController(); 

  void _verificarAcceso() {
    if (_passController.text.trim() == _claveCorrecta) {
      setState(() {
        _isLoggedIn = true;
        _mensajeError = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bienvenida al Panel de Empleados!')),
      );
    } else {
      setState(() {
        _mensajeError = "Contraseña incorrecta. (Usa: admin123)";
      });
    }
  }

  void _agregarProductoDirecto() {
    if (_formKey.currentState!.validate()) {
      // Convertimos el texto separado por comas (ej: "35, 36, 37" o "S, M, L") en una lista de Strings
      List<String> tallasLista = _tallasController.text.isNotEmpty
          ? _tallasController.text.split(',').map((t) => t.trim()).toList()
          : ['Única'];

      setState(() {
        GlobalData.productList.add(
          Producto(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: _nombreController.text,
            categoria: _categoriaController.text,
            precio: double.tryParse(_precioController.text) ?? 0.0,
            descripcion: _descripcionController.text.isEmpty ? 'Sin descripción' : _descripcionController.text,
            tallas: tallasLista, 
            colores: ['Rosado'], 
          ),
        );
      });

      // Limpiar los campos después de guardar
      _nombreController.clear();
      _categoriaController.clear();
      _precioController.clear();
      _descripcionController.clear();
      _tallasController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto agregado al catálogo con éxito! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color colorRosaOscuro = Colors.pinkAccent;

    if (_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Empleados - Genali'),
          backgroundColor: const Color(0xFFFFF0F5),
          foregroundColor: colorRosaOscuro,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Cerrar sesión',
              onPressed: () => setState(() => _isLoggedIn = false),
            )
          ],
        ),
        backgroundColor: const Color(0xFFFFF0F5),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✨ Agregar Nuevo Producto al Catálogo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorRosaOscuro),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del producto',
                            prefixIcon: Icon(Icons.shopping_bag, color: colorRosaOscuro),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category, color: colorRosaOscuro),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese la categoría' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _precioController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio (Lps)',
                            prefixIcon: Icon(Icons.attach_money, color: colorRosaOscuro),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese el precio' : null,
                        ),
                        const SizedBox(height: 12),
                        // 🌟 Campo nuevo para las Tallas
                        TextFormField(
                          controller: _tallasController,
                          decoration: const InputDecoration(
                            labelText: 'Tallas (separadas por comas, ej: 36, 37, 38)',
                            prefixIcon: Icon(Icons.straighten, color: colorRosaOscuro),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese al menos una talla' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            prefixIcon: Icon(Icons.description, color: colorRosaOscuro),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorRosaOscuro,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _agregarProductoDirecto,
                            child: const Text('Guardar en el Catálogo', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                '📦 Gestión de Pedidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check_circle, color: Colors.white),
                  ),
                  title: const Text('Pedidos Hechos', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Ver historial de compras completadas'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pedidos Hechos'),
                        content: const Text('• Pedido #101 - Crocs Classic (Entregado)\n• Pedido #102 - Tenis Deportivos (En camino)'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.cancel, color: Colors.white),
                  ),
                  title: const Text('Pedidos Cancelados', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Ver pedidos anulados'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pedidos Cancelados'),
                        content: const Text('• Pedido #098 - Sandalias (Cancelado por el usuario)'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso de Personal - Genali'),
        backgroundColor: const Color(0xFFF7F4F0),
        foregroundColor: colorRosaOscuro,
      ),
      backgroundColor: const Color(0xFFF7F4F0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: colorRosaOscuro),
            const SizedBox(height: 20),
            const Text(
              'Área Restringida para Empleados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorRosaOscuro),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passController,
              obscureText: true,
              onSubmitted: (_) => _verificarAcceso(),
              decoration: InputDecoration(
                labelText: 'Clave de Acceso (admin123)',
                prefixIcon: const Icon(Icons.lock, color: colorRosaOscuro),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 10),
            if (_mensajeError.isNotEmpty)
              Text(
                _mensajeError,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRosaOscuro,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _verificarAcceso,
              child: const Text('Ingresar al Sistema', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}