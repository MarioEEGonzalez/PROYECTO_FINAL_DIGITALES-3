import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ergo_alert/main.dart';
import 'package:ergo_alert/providers/posture_provider.dart';

void main() {
  testWidgets('ErgoAlert smoke test', (WidgetTester tester) async {
    // Construimos nuestra app envolviéndola en el Provider que creamos
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PostureProvider(),
        child: const ErgoAlertApp(),
      ),
    );

    // Verificamos que la app arranca y muestra el texto por defecto
    expect(find.text('BUSCANDO HARDWARE...'), findsOneWidget);
  });
}