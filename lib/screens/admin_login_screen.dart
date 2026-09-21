import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String baseUrl = 'http://localhost:3000';
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String correo = _emailController.text.trim();

        // 1. Validación para el Gerente General
        if (correo == 'genesismartniez@gmail.com') {
          if (!mounted) return;
          // Redirige al panel de gerente
          Navigator.pushReplacementNamed(context, '/home_gerente');
          return;
        }

        // 2. Petición al backend para verificar empleados u otros usuarios registrados
        final response = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'correo': correo,
            'password': _passwordController.text.trim(),
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String rol = data['rol'] ?? 'empleado'; // 'gerente' o 'empleado'

          if (rol == 'gerente') {
            Navigator.pushReplacementNamed(context, '/home_gerente');
          } else {
            // Redirige al panel de empleado con sus opciones limitadas
            Navigator.pushReplacementNamed(context, '/catalogo');
          }
        } else {
          // Fallback temporal por si el endpoint del backend falla pero quieres probar al empleado
          if (correo.contains('empleado') || correo.contains('genali.com')) {
            Navigator.pushReplacementNamed(context, '/catalogo');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Correo o contraseña incorrectos'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } catch (e) {
        // Fallback offline de emergencia para asegurar que puedas entrar con ambos roles
        String correo = _emailController.text.trim();
        if (!mounted) return;
        
        if (correo == 'genesismartniez@gmail.com') {
          Navigator.pushReplacementNamed(context, '/home_gerente');
        } else {
          Navigator.pushReplacementNamed(context, '/catalogo');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variedades Genali - Acceso'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.storefront, size: 80, color: Colors.pinkAccent),
              const SizedBox(height: 20),
              const Text(
                '¡Bienvenida a Variedades Genali!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico (Gerente o Empleado)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _iniciarSesion,
                      child: const Text('Ingresar al Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}