import 'package:flutter/material.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  // Lista simulada de usuarios con estado activo/inactivo
  final List<Map<String, dynamic>> _usuarios = [
    {'nombre': 'Juan Pérez', 'correo': 'juan@genali.com', 'activo': true, 'ventas': 12},
    {'nombre': 'María Gómez', 'correo': 'maria@genali.com', 'activo': true, 'ventas': 8},
    {'nombre': 'Carlos Ruiz', 'correo': 'carlos@genali.com', 'activo': false, 'ventas': 3},
  ];

  void _toggleEstado(int index) {
    setState(() {
      _usuarios[index]['activo'] = !_usuarios[index]['activo'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado de ${_usuarios[index]['nombre']} actualizado correctamente.'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activar / Desactivar Perfiles'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          final bool activo = usuario['activo'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: activo ? Colors.pink[100] : Colors.grey[300],
                child: Icon(Icons.person, color: activo ? Colors.pinkAccent : Colors.grey),
              ),
              title: Text(usuario['nombre'], style: TextStyle(fontWeight: FontWeight.bold, color: activo ? Colors.black : Colors.grey)),
              subtitle: Text('${usuario['correo']}\nVentas realizadas registradas: ${usuario['ventas']}'),
              isThreeLine: true,
              trailing: Switch(
                value: activo,
                activeColor: Colors.pinkAccent,
                onChanged: (val) => _toggleEstado(index),
              ),
            ),
          );
        },
      ),
    );
  }
}