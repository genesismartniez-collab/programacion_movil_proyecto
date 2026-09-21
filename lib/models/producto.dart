class Producto {
  final int? id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;

  Producto({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: double.parse(json['precio'].toString()),
      stock: int.parse(json['stock'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
    };
  }
}