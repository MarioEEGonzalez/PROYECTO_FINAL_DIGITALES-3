import 'package:flutter/material.dart';
import 'dart:math' as math;

class PostureAvatar extends StatelessWidget {
  // Ahora representan: 1. Base Cráneo, 2. C7 (Base cuello), 3. Mitad Espalda
  final double cervical; 
  final double cuello;
  final double lumbar;

  const PostureAvatar({
    super.key,
    required this.cervical,
    required this.cuello,
    required this.lumbar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 400,
      child: CustomPaint(
        painter: MedicalSpinePainter(
          craneo: cervical,
          c7: cuello,
          espaldaMedia: lumbar,
        ),
      ),
    );
  }
}

class MedicalSpinePainter extends CustomPainter {
  final double craneo;
  final double c7;
  final double espaldaMedia;

  MedicalSpinePainter({
    required this.craneo,
    required this.c7,
    required this.espaldaMedia,
  });

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculamos el nivel de "peligro" global (si los ángulos suman mucho, se pone rojo)
    double tensionTotal = craneo.abs() + c7.abs() + espaldaMedia.abs();
    Color healthColor = tensionTotal > 40 ? Colors.redAccent : 
                        tensionTotal > 20 ? Colors.orangeAccent : Colors.greenAccent;

    // --- Pinceles de Alta Calidad ---
    // Silueta del cuerpo (Translúcida)
    final paintBody = Paint()
      ..color = Colors.greenAccent.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // Línea de la columna (Brillo neón)
    final paintSpineGlow = Paint()
      ..color = healthColor.withOpacity(0.4)
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    // Vértebras (Puntos blancos)
    final paintVertebra = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // --- Cinemática (Puntos de anclaje) ---
    double startX = size.width / 2;
    double startY = size.height - 40; // Base (Espalda baja / Cadera fija)

    // Segmento 3: Mitad de la Espalda (Sensor 3)
    double anguloEspalda = _toRadians(espaldaMedia);
    double lenEspalda = 110.0;
    double p1X = startX + math.sin(anguloEspalda) * lenEspalda;
    double p1Y = startY - math.cos(anguloEspalda) * lenEspalda;

    // Segmento 2: Base del Cuello C7 (Sensor 2)
    double anguloC7 = _toRadians(espaldaMedia + c7);
    double lenC7 = 90.0;
    double p2X = p1X + math.sin(anguloC7) * lenC7;
    double p2Y = p1Y - math.cos(anguloC7) * lenC7;

    // Segmento 1: Base del Cráneo (Sensor 1)
    double anguloCraneo = _toRadians(espaldaMedia + c7 + craneo);
    double lenCraneo = 50.0;
    double p3X = p2X + math.sin(anguloCraneo) * lenCraneo;
    double p3Y = p2Y - math.cos(anguloCraneo) * lenCraneo;

    // --- Dibujo de la Silueta (Fondo) ---
    // Dibujamos un óvalo grueso que envuelve la columna (Torso)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(p1X, p1Y + 30), width: 120, height: 200), 
      paintBody
    );
    // Dibujamos la Cabeza
    double headCenterX = p3X + math.sin(anguloCraneo) * 30;
    double headCenterY = p3Y - math.cos(anguloCraneo) * 30;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headCenterX, headCenterY), width: 80, height: 100), 
      paintBody
    );

    // --- Dibujo de la Columna (Curva suave de Bézier) ---
    Path spinePath = Path();
    spinePath.moveTo(startX, startY);
    // Crea una curva suave pasando por los 3 sensores
    spinePath.quadraticBezierTo(p1X, p1Y, p2X, p2Y);
    spinePath.lineTo(p3X, p3Y);

    // Dibujamos el brillo de la columna
    canvas.drawPath(spinePath..fillType = PathFillType.evenOdd, 
      paintSpineGlow..style = PaintingStyle.stroke);

    // --- Dibujo de las Vértebras (Detalle realista) ---
    // En lugar de una sola línea, dibujamos puntos a lo largo de la columna
    _drawVertebra(canvas, startX, startY, paintVertebra); // Base
    _drawVertebra(canvas, (startX + p1X)/2, (startY + p1Y)/2, paintVertebra);
    _drawVertebra(canvas, p1X, p1Y, paintVertebra); // Sensor 3
    _drawVertebra(canvas, (p1X + p2X)/2, (p1Y + p2Y)/2, paintVertebra);
    _drawVertebra(canvas, p2X, p2Y, paintVertebra); // Sensor 2 (C7)
    _drawVertebra(canvas, (p2X + p3X)/2, (p2Y + p3Y)/2, paintVertebra);
    _drawVertebra(canvas, p3X, p3Y, paintVertebra); // Sensor 1 (Cráneo)

    // Punto rojo para el centro de gravedad de la cabeza (Ojo/Oreja)
    canvas.drawCircle(Offset(headCenterX, headCenterY), 5, Paint()..color = healthColor);
  }

  // Función auxiliar para dibujar cada vértebra como un bloque
  void _drawVertebra(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 14, height: 8), 
        const Radius.circular(2)
      ), 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant MedicalSpinePainter oldDelegate) => true;
}