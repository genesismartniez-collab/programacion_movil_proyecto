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

// Lista global para compartir los productos entre el panel de empleados y el catálogo
class GlobalData {
  static List<Producto> productList = [
    Producto(
      id: '1',
      nombre: 'Crocs Classic Pink',
      categoria: 'Calzado',
      precio: 650.0,
      descripcion: 'Cómodos y ligeros para uso diario',
      tallas: ['36', '37', '38'],
      colores: ['Rosado', 'Blanco'],
    ),
    Producto(
      id: '2',
      nombre: 'Tenis Deportivos',
      categoria: 'Calzado',
      precio: 1200.0,
      descripcion: 'Ideales para running y ejercicio',
      tallas: ['37', '39', '40'],
      colores: ['Negro', 'Rosa'],
    ),
  ];
}