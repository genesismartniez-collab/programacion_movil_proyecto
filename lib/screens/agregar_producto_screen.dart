import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? _categoria;
  bool _cargando = false;
  bool _esFavorito = false;
  bool _activo = true;
  XFile? _imagen;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl = 'http://localhost:3000';

  static const Color _rosaFuerte = Color(0xFFFFADCD);
  static const Color _textoOscuro = Color(0xFF1F2430);
  static const Color _textoGris = Color(0xFF8A909C);

  final List<String> _categorias = [
    'Calzado', 'Accesorios', 'Vestido Dama', 'Caballero',
    'Niño', 'Niña', 'Fútbol', 'Camiseta Deportiva', 'Perfumería',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _tallaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen(ImageSource fuente) async {
    try {
      final XFile? foto = await _picker.pickImage(source: fuente, imageQuality: 80, maxWidth: 1200);
      if (foto != null) setState(() => _imagen = foto);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la imagen: $e')),
      );
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _rosaFuerte),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _elegirImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _rosaFuerte),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _elegirImagen(ImageSource.camera);
              },
            ),
            if (_imagen != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Quitar foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagen = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    setState(() => _cargando = true);

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/productos'));
      request.fields['nombre'] = _nombreController.text.trim();
      request.fields['categoria'] = _categoria!;
      request.fields['precio'] = _precioController.text.trim();
      request.fields['stock'] = _stockController.text.trim();
      request.fields['tallas'] = _tallaController.text.trim();
      request.fields['descripcion'] = _descripcionController.text.trim();
      request.fields['activo'] = _activo.toString();
      request.fields['esFavorito'] = _esFavorito.toString();

      if (_imagen != null) {
        request.files.add(await http.MultipartFile.fromPath('imagen', _imagen!.path));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ ¡Producto guardado en la base de datos!'), backgroundColor: _rosaFuerte),
        );
        Navigator.pop(context, data['producto']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error del servidor (Código: ${response.statusCode})'), backgroundColor: Colors.orangeAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error de conexión con la BD: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildTarjetaInfo(),
                    const SizedBox(height: 16),
                    _buildFotoYPreview(),
                    const SizedBox(height: 16),
                    _buildCampo(
                      controller: _nombreController,
                      label: 'Nombre del producto',
                      obligatorio: true,
                      icono: Icons.shopping_bag,
                      hint: 'Ej. Camiseta Oficial Selección',
                    ),
                    const SizedBox(height: 14),
                    _buildDropdownCategoria(),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildCampo(
                            controller: _precioController,
                            label: 'Precio (L.)',
                            obligatorio: true,
                            icono: Icons.attach_money,
                            hint: '0.00',
                            teclado: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCampo(
                            controller: _stockController,
                            label: 'Cantidad en stock',
                            obligatorio: true,
                            icono: Icons.inventory_2_outlined,
                            hint: '0',
                            teclado: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      controller: _tallaController,
                      label: 'Tallas (separadas por coma)',
                      icono: Icons.straighten,
                      hint: 'Ej. S, M, L, XL',
                    ),
                    const SizedBox(height: 14),
                    _buildCampoDescripcion(),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      icono: Icons.star_border,
                      titulo: 'Marcar como "Lo más vendido"',
                      subtitulo: 'Este producto se mostrará como destacado.',
                      valor: _esFavorito,
                      onChanged: (v) => setState(() => _esFavorito = v),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitch(
                      icono: Icons.inventory_2_outlined,
                      titulo: 'Producto activo',
                      subtitulo: 'El producto estará disponible en el catálogo.',
                      valor: _activo,
                      onChanged: (v) => setState(() => _activo = v),
                    ),
                    const SizedBox(height: 24),
                    _buildBotonGuardar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Encabezado ----------
  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 52, 16, 18),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agregar Producto',
                    style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                Text('Variedades Genali', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 30),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ---------- Tarjeta info ----------
  Widget _buildTarjetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, color: _rosaFuerte),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completa la información del producto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textoOscuro)),
                SizedBox(height: 2),
                Text('Los campos con * son obligatorios.',
                    style: TextStyle(color: _textoGris, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Foto + vista previa ----------
  Widget _buildFotoYPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _mostrarOpcionesFoto,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _rosaFuerte.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 42, color: _rosaFuerte),
                  SizedBox(height: 10),
                  Text('Agregar foto del producto',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _rosaFuerte, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Toca para subir una imagen',
                      style: TextStyle(color: _textoGris, fontSize: 12)),
                  Text('JPG, PNG (Máx. 5MB)', style: TextStyle(color: _textoGris, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 190,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E6EB)),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Vista previa', style: TextStyle(color: _textoGris, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imagen == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 34, color: _textoGris),
                              SizedBox(height: 6),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('La imagen se mostrará aquí',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: _textoGris, fontSize: 11)),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_imagen!.path), fit: BoxFit.cover, width: double.infinity),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Campo de texto tipo tarjeta ----------
  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    bool obligatorio = false,
    String? hint,
    TextInputType? teclado,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icono, color: _rosaFuerte, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: teclado,
              style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600),
              validator: obligatorio ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null : null,
              decoration: InputDecoration(
                labelText: obligatorio ? '$label *' : label,
                labelStyle: const TextStyle(color: _textoGris, fontSize: 14, fontWeight: FontWeight.w500),
                hintText: hint,
                hintStyle: const TextStyle(color: _textoGris, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Dropdown categoría ----------
  Widget _buildDropdownCategoria() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.category_outlined, color: _rosaFuerte, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _categoria,
              isExpanded: true,
              style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600, fontSize: 15),
              icon: const Icon(Icons.keyboard_arrow_down, color: _textoGris),
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                labelStyle: TextStyle(color: _textoGris, fontSize: 14, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              hint: const Text('Selecciona una categoría', style: TextStyle(color: _textoGris, fontWeight: FontWeight.normal)),
              items: _categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v),
              validator: (v) => v == null ? 'Selecciona una categoría' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Campo descripción ----------
  Widget _buildCampoDescripcion() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.description_outlined, color: _rosaFuerte, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              maxLength: 200,
              style: const TextStyle(color: _textoOscuro, fontWeight: FontWeight.w600),
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              decoration: const InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: _textoGris, fontSize: 14, fontWeight: FontWeight.w500),
                hintText: 'Descripción del producto (opcional)',
                hintStyle: TextStyle(color: _textoGris, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                counterStyle: TextStyle(color: _textoGris),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Switch tipo tarjeta ----------
  Widget _buildSwitch({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFDECF4), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icono, color: _rosaFuerte, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: _textoOscuro, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(color: _textoGris, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: valor, activeThumbColor: Colors.white, activeTrackColor: _rosaFuerte, onChanged: onChanged),
        ],
      ),
    );
  }

  // ---------- Botón guardar ----------
  Widget _buildBotonGuardar() {
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
        onPressed: _cargando ? null : _guardarProducto,
        child: _cargando
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 22),
                  SizedBox(width: 10),
                  Text('Guardar Producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }
}
