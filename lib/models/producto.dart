class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;
  final List<String> tallas;
  final List<String> colores;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.tallas,
    required this.colores,
  });
}