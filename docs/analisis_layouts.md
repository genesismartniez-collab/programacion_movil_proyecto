# Análisis de Layouts y Navegación — Variedades Genali

**Estudiante:** Génesis Martínez 
**Estudiante:** Emily  Martínez 

**Asignatura:** Programación Móvil (CEUTEC)  
**Proyecto:** Variedades Genali  

---

## 4.1 Inventario de Pantallas

| # | Pantalla | Layout principal | Justificación |
|---|---|---|---|
| 1 | **Login** (`login_screen.dart`) | Column + SingleChildScrollView | Formulario de acceso que se adapta y permite desplazamiento en pantallas de diferentes tamaños. |
| 2 | **Home / Dashboard** (`home_screen.dart`) | Column con IndexedStack y BottomNavigationBar | KPIs y accesos rápidos arriba, con navegación inferior persistente que mantiene el estado entre pestañas. |
| 3 | **Catálogo** (`catalog_screen.dart`) | GridView.builder (2 columnas) | Optimizado para mostrar productos con imagen prominente y precio mediante renderizado eficiente (lazy loading). |
| 4 | **Detalle de Producto** (`product_detail_screen.dart`) | SingleChildScrollView con Column | Contenido detallado del calzado o accesorio que requiere scroll vertical para ver toda la información y acciones. |
| 5 | **Carrito / Resumen** (`cart_screen.dart`) | Column + Expanded + botón fijo | Elementos de la compra scrolleables en la parte superior con el resumen total y botón de pago fijos abajo. |
| 6 | **Perfil y Configuración** (`profile_screen.dart`) | ListView con Card y ListTile | Estructura limpia tipo panel de control estilo *Settings* para gestionar los datos de usuario y opciones de tienda. |

---

## 4.2 Mapa de navegación

El flujo de navegación de la aplicación se estructura de la siguiente manera mediante rutas con nombre centralizadas en `main.dart`:

1. **Pantalla Raíz / Splash**: Al iniciar la app, se direcciona a la pantalla de bienvenida o login.
2. **Login (`/login`)**: Pantalla inicial de autenticación. Al validar el ingreso correctamente, utiliza `Navigator.pushNamedAndRemoveUntil` para limpiar la pila de navegación y llevar al usuario al `Home`.
3. **Home (`/home`)**: Pantalla principal que actúa como contenedor central mediante un menú lateral (`Drawer`) y barra de navegación inferior (`BottomNavigationBar`), permitiendo alternar entre:
   - Inicio
   - Catálogo (`/catalogo`)
   - Carrito (`/carrito`)
   - Perfil (`/profile`)
4. **Detalle (`/detalle`)**: Se accede presionando cualquier tarjeta de producto desde el Catálogo o el Home mediante `Navigator.pushNamed(context, '/detalle', arguments: producto)`, recibiendo los datos mediante `ModalRoute`.
5. **Puntos de retorno**: Las pantallas secundarias de detalle o formularios disponen del botón de retroceso automático de Flutter o acciones de cierre controladas.

---

## 4.3 Decisiones de diseño técnicas

1. **Uso de `GridView.builder` para el catálogo de productos**
   - *Justificación:* Los artículos de calzado y moda de Variedades Genali requieren una presentación visual atractiva en cuadrícula de dos columnas (`crossAxisCount: 2`). El uso del constructor con `builder` garantiza un rendimiento óptimo mediante *lazy loading* (renderizando únicamente los elementos visibles en pantalla).

2. **Implementación de `Navigator.pushNamedAndRemoveUntil` tras el inicio de sesión**
   - *Justificación:* Una vez que el usuario completa su autenticación de forma exitosa, se bloquea la posibilidad de regresar al login presionando el botón físico o virtual de retroceso del dispositivo, limpiando por completo el historial de la pila de navegación hacia la ruta principal (`/home`).

3. **Uso de `IndexedStack` en conjunto con `BottomNavigationBar` en el Home**
   - *Justificación:* Para mantener una experiencia de usuario fluida sin recargar las pestañas principales de la tienda al cambiar entre secciones (Inicio, Catálogo, Carrito y Perfil), se implementó un `IndexedStack` que preserva el estado de cada vista activa de forma instantánea.