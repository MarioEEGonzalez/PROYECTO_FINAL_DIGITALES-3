import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/udp_service.dart';

class PostureProvider extends ChangeNotifier {
  // =================================================
  // 1. ESTADO ORIGINAL: Ángulos en tiempo real
  // =================================================
  SensorData? _currentData;
  final UdpService _udpService = UdpService();

  SensorData? get currentData => _currentData;

  // =================================================
  // 2. NUEVO ESTADO: Estadísticas históricas
  // =================================================
  int statScore = 0;
  int statSaludableMin = 0;
  int statMalaMin = 0;
  int statCriticaMin = 0;
  int statAlarmas = 0;

  PostureProvider() {
    // Empezamos a escuchar en el puerto 5005 (puedes cambiarlo)
    _udpService.startListening(5005, (json) {
      // CASO A: Verificamos si el paquete que llegó es el de ESTADÍSTICAS
      if (json['type'] == 'stats_response') {
        final stats = json['data'];
        if (stats != null) {
          statScore = stats['score'] ?? 0;
          statSaludableMin = stats['saludable_min'] ?? 0;
          statMalaMin = stats['mala_min'] ?? 0;
          statCriticaMin = stats['critica_min'] ?? 0;
          statAlarmas = stats['alarmas'] ?? 0;
        }
        notifyListeners(); // Refresca la pantalla de estadísticas
      }
      // CASO B: Si no es de estadísticas, asumimos que son los ÁNGULOS (SensorData)
      else {
        _currentData = SensorData.fromJson(json);
        notifyListeners(); // Refresca el muñeco o la pantalla principal
      }
    });
  }
}
