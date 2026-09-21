import 'package:flutter/material.dart';

/// Umbral: si el stock queda en este número o menos, se avisa.
const int kStockBajo = 10;

/// Muestra una notificación tipo banner cuando un producto queda con stock bajo.
/// Funciona en cualquier plataforma (no necesita permisos ni servidor).
void mostrarAlertaStockBajo(BuildContext context, String nombre, int stock) {
  if (stock > kStockBajo) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearMaterialBanners();

  final bool agotado = stock <= 0;
  final Color fondo = agotado ? const Color(0xFFFDE2E1) : const Color(0xFFFFF3CD);
  final Color acento = agotado ? Colors.redAccent : const Color(0xFFB8860B);

  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: fondo,
      leading: Icon(agotado ? Icons.error_outline : Icons.warning_amber_rounded, color: acento),
      content: Text(
        agotado
            ? '¡"$nombre" se agotó! Reabastece el inventario.'
            : 'Stock bajo: "$nombre" — quedan $stock unidades.',
        style: TextStyle(color: acento.withValues(alpha: 0.95), fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton(
          onPressed: () => messenger.hideCurrentMaterialBanner(),
          child: Text('Entendido', style: TextStyle(color: acento, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  // Se oculta solo después de unos segundos.
  Future.delayed(const Duration(seconds: 6), () {
    try {
      messenger.hideCurrentMaterialBanner();
    } catch (_) {}
  });
}
