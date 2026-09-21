/// Guarda los datos del usuario que inició sesión, disponibles en toda la app.
class Sesion {
  static String nombre = '';
  static String correo = '';
  static String rol = 'empleado';

  static bool get esGerente => rol.toLowerCase() == 'gerente';
  static bool get haySesion => correo.isNotEmpty;

  static void guardar({required String nombre, required String correo, required String rol}) {
    Sesion.nombre = nombre;
    Sesion.correo = correo;
    Sesion.rol = rol;
  }

  static void limpiar() {
    nombre = '';
    correo = '';
    rol = 'empleado';
  }
}
