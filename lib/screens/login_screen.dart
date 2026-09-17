import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variable para alternar entre modo Registro (true) y modo Login (false)
  bool _isRegistering = false;

  // Controladores para los campos
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // IP estándar del emulador de Android hacia la PC
  final String baseUrl = 'http://10.0.2.2:3000';

  // Validación flexible y rápida
  bool _validarCorreo(String correo) {
    return correo.contains('@') && correo.contains('.');
  }

  // Función unificada para manejar Login o Registro según la vista activa
  Future<void> _submitForm() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    // 1. Validaciones según el modo
    if (_isRegistering) {
      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();
      final confirmPassword = _confirmPasswordController.text;

      if (nombre.isEmpty || apellido.isEmpty || correo.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        _mostrarMensaje('Por favor, completa todos los campos.');
        return;
      }
      if (!_validarCorreo(correo)) {
        _mostrarMensaje('Ingresa un correo electrónico válido.');
        return;
      }
      if (password.length < 6) {
        _mostrarMensaje('La contraseña debe tener al menos 6 caracteres.');
        return;
      }
      if (password != confirmPassword) {
        _mostrarMensaje('Las contraseñas no coinciden.');
        return;
      }
    } else {
      if (correo.isEmpty || password.isEmpty) {
        _mostrarMensaje('Por favor, ingresa tu correo y contraseña.');
        return;
      }
    }

    setState(() { _isLoading = true; });

    // Definir el endpoint dinámicamente: /users para registro o /login para iniciar sesión
    final endpoint = _isRegistering ? '/users' : '/login';
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final bodyData = _isRegistering
          ? {
              'nombre': _nombreController.text.trim(),
              'apellido': _apellidoController.text.trim(),
              'correo': correo,
              'contrasena': password,
            }
          : {
              'correo': correo,
              'contrasena': password,
            };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      // Imprimimos en la consola de VS Code para depurar si el servidor responde algo
      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      // Validamos si la respuesta del servidor viene en formato JSON válido
      final data = jsonDecode(response.body);

      if (_isRegistering && response.statusCode == 201) {
        _mostrarMensaje(data['mensaje'] ?? 'Usuario registrado correctamente.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (!_isRegistering && response.statusCode == 200) {
        _mostrarMensaje(data['mensaje'] ?? 'Inicio de sesión exitoso');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _mostrarMensaje(data['error'] ?? data['mensaje'] ?? 'Ocurrió un error en el servidor.');
      }
    } catch (e) {
      // Imprimimos el error exacto en la consola de desarrollo para saber qué falló
      print('Error de conexión detallado: $e');
      _mostrarMensaje('No se pudo conectar al servidor. Verifica que esté encendido.');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 70, color: Colors.pinkAccent),
                const SizedBox(height: 16),
                Text(
                  _isRegistering ? 'Variedades Genali - Registro' : 'Variedades Genali - Ingresar',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 30),

                // Campos extra que solo se muestran si está registrándose
                if (_isRegistering) ...[
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campos comunes (Correo y Contraseña)
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar contraseña (solo para registro)
                if (_isRegistering) ...[
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isRegistering ? 'REGISTRARSE' : 'INGRESAR',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón para cambiar entre Iniciar Sesión y Registrarse
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? '¿Ya tienes una cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Regístrate aquí',
                    style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}