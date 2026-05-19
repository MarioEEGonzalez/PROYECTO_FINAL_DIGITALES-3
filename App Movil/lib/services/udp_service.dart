import 'dart:io';
import 'dart:convert';
import 'dart:async';

class UdpService {
  RawDatagramSocket? _socket;
  
  // Función para empezar a escuchar
  Future<void> startListening(int port, Function(Map<String, dynamic>) onDataReceived) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    print("Servidor UDP activo en puerto $port");

    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = _socket?.receive();
        if (dg != null) {
          String message = utf8.decode(dg.data);
          try {
            onDataReceived(jsonDecode(message));
          } catch (e) {
            print("Error decodificando JSON: $e");
          }
        }
      }
    });
  }

  void stop() {
    _socket?.close();
  }
}