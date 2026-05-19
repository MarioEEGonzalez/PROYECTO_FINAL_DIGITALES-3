import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class NetworkService {
  // =========================================================================
  // CONFIGURACIÓN DE HARDWARE (¡Única línea que cambiarás a futuro!)
  // =========================================================================
  static const String _raspberryIp =
      "192.168.1.51"; // <-- Pon aquí la IP de tu PC/Raspberry
  static const int _raspberryPort = 5006;

  /// 1. Notifica a la Raspberry que el usuario cambió
  static void sendActiveUser(int user) {
    _sendUdpPacket({"type": "set_user", "user": user});
  }

  /// 2. Envía los promedios de calibración para guardarse en la Flash
  static void sendCalibration({
    required int user,
    required List<double> cervicalList,
    required List<double> cuelloList,
    required List<double> lumbarList,
  }) {
    if (cervicalList.isEmpty) return;

    double avgCervical =
        cervicalList.reduce((a, b) => a + b) / cervicalList.length;
    double avgCuello = cuelloList.reduce((a, b) => a + b) / cuelloList.length;
    double avgLumbar = lumbarList.reduce((a, b) => a + b) / lumbarList.length;

    _sendUdpPacket({
      "type": "calibrate",
      "user": user,
      "cervical": avgCervical,
      "cuello": avgCuello,
      "lumbar": avgLumbar,
    });
  }

  /// 3. Solicita las estadísticas guardadas ("hoy" o "semana")
  static void requestLiveStatistics(int user, String viewTime) {
    _sendUdpPacket({"type": "request_stats", "user": user, "view": viewTime});
  }

  /// Función interna de bajo nivel para inyectar datos en la red
  static void _sendUdpPacket(Map<String, dynamic> payload) {
    try {
      final address = InternetAddress.tryParse(_raspberryIp);
      if (address == null) return;

      RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((
        RawDatagramSocket socket,
      ) {
        socket.send(utf8.encode(jsonEncode(payload)), address, _raspberryPort);
        socket.close();
        debugPrint("📤 [UDP ENVIADO]: ${jsonEncode(payload)}");
      });
    } catch (e) {
      debugPrint("❌ Error en transferencia UDP: $e");
    }
  }
}
