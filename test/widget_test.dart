import 'package:flutter_test/flutter_test.dart';
import 'package:programacion_movil_proyecto/main.dart';

void main() {
  testWidgets('Carga inicial de Variedades Genali', (WidgetTester tester) async {
    // Construye la aplicación usando la clase principal correcta
    await tester.pumpWidget(const VariedadesGenaliApp());

    // Verifica que el widget inicial cargue correctamente
    expect(find.byType(VariedadesGenaliApp), findsOneWidget);
  });
}