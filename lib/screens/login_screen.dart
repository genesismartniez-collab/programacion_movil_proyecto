import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String baseUrl = 'http://localhost:3000'; // Tu API en Node.js

  bool _ocultarPassword = true;
  bool _recordarme = true;
  bool _cargando = false;

  static const Color _rosaFuerte = Color(0xFFF0338D);
  static const Color _rosaClaro = Color(0xFFFF6FB0);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validamos si es gerente o empleado según el rol que devuelva la BD o el correo
        String rol = (data['rol'] == 'gerente' || _emailController.text.trim().contains('admin')) ? 'gerente' : 'empleado';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenida a Variedades Genali ($rol)! 🌸'),
            backgroundColor: _rosaFuerte,
          ),
        );

        // Redirige según el rol correspondiente
        Navigator.pushReplacementNamed(
          context,
          rol == 'gerente' ? '/home_gerente' : '/catalogo',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEncabezado(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: _textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inicia sesión para continuar con la gestión de tus productos.',
                      style: TextStyle(fontSize: 16, color: _textoGris, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    _buildCampoTexto(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      icono: Icons.mail_outline,
                      teclado: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildCampoTexto(
                      controller: _passwordController,
                      label: 'Contraseña',
                      icono: Icons.lock_outline,
                      obscure: _ocultarPassword,
                      sufijo: IconButton(
                        icon: Icon(
                          _ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: _textoGris,
                        ),
                        onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecordarmeFila(),
                    const SizedBox(height: 24),
                    _buildBotonIngresar(),
                    const SizedBox(height: 32),
                    _buildPieDePagina(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return ClipPath(
      clipper: _EncabezadoClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_rosaFuerte, _rosaClaro],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 40),
                const SizedBox(width: 12),
                const Text(
                  'Genali',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.inventory_2_outlined, color: Colors.white.withValues(alpha: 0.85), size: 46),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Gestión de Productos',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            Container(width: 40, height: 3, color: Colors.white70),
            const SizedBox(height: 14),
            Text(
              'Organiza, controla y haz crecer tu negocio.',
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.95), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    bool obscure = false,
    Widget? sufijo,
    TextInputType? teclado,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: teclado,
      style: const TextStyle(color: _textoOscuro, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textoGris),
        prefixIcon: Icon(icono, color: _textoGris),
        suffixIcon: sufijo,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE3E6EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE3E6EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _rosaFuerte, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildRecordarmeFila() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _recordarme,
                activeColor: _rosaFuerte,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (v) => setState(() => _recordarme = v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Recordarme', style: TextStyle(color: _textoOscuro, fontSize: 15)),
          ],
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contacta a tu gerente para recuperar el acceso.')),
            );
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(color: _rosaFuerte, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonIngresar() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _rosaFuerte,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _rosaFuerte.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _cargando ? null : _iniciarSesion,
        child: _cargando
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ingresar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 22),
                ],
              ),
      ),
    );
  }

  Widget _buildPieDePagina() {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE3E6EB))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _textoGris),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE3E6EB))),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Sistema de gestión de productos', style: TextStyle(color: _textoGris, fontSize: 13)),
          const SizedBox(height: 2),
          const Text('Genali', style: TextStyle(color: _textoOscuro, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Recorta la parte inferior del encabezado con una curva suave.
class _EncabezadoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.55,
      size.height - 24,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height - 48,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
