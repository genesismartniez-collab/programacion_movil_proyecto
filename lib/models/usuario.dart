class Usuario {
  
  final String id;
  final String nombre;
  final String correo;
  final String rol;


  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  String obtenerDatosResumidos() {
    return '$nombre ($rol) - $correo';
  }
}