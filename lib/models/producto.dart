class Producto {

  final String id;
  final String nombre;
  final double precio;
  final String imagenUrl;
  final String descripcion;

  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    required this.descripcion,
  });

  double calcularPrecioConDescuento(double porcentaje) {
    return precio - (precio * (porcentaje / 100));
  }
}