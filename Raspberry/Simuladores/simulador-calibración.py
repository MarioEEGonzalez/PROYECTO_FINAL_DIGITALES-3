import socket
import json
import time
import random
import threading

# ==========================================
# CONFIGURACIÓN DE RED
# ==========================================
# 1. Para ENVIAR datos al celular:
UDP_IP_CELULAR = "192.168.1.50"  # <--- IP de tu celular/emulador
UDP_PORT_CELULAR = 5005

# 2. Para ESCUCHAR lo que envía el celular:
# '0.0.0.0' significa que escuchará en todas las interfaces de red disponibles
UDP_IP_ESCUCHA = "0.0.0.0"  
UDP_PORT_ESCUCHA = 5006  # El puerto que configuramos en Flutter

# Configuración del socket de envío
sock_enviar = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Configuración y enlace (bind) del socket de escucha
sock_recibir = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_recibir.bind((UDP_IP_ESCUCHA, UDP_PORT_ESCUCHA))

# Ángulos base iniciales (Postura Perfecta)
angulos_base = {
    "cervical": 0.0,
    "cuello": 0.0,
    "lumbar": 0.0
}

# Variable para rastrear qué usuario está activo según Flutter
usuario_activo = 1

# ==========================================
# HILOS EN SEGUNDO PLANO (BACKGROUND THREADS)
# ==========================================

def enviar_datos():
    """Hilo 1: Envía ángulos simulados al celular constantemente (10 Hz)"""
    while True:
        datos_simulados = {
            "cervical": angulos_base["cervical"] + random.uniform(-1.0, 1.0),
            "cuello": angulos_base["cuello"] + random.uniform(-1.0, 1.0),
            "lumbar": angulos_base["lumbar"] + random.uniform(-1.0, 1.0)
        }
        
        mensaje = json.dumps(datos_simulados).encode('utf-8')
        try:
            sock_enviar.sendto(mensaje, (UDP_IP_CELULAR, UDP_PORT_CELULAR))
        except Exception as e:
            # Evita que se caiga el script si hay un problema temporal de red
            pass
        time.sleep(0.1)

def escuchar_datos():
    """Hilo 2: Se queda esperando mensajes entrantes de la app de Flutter"""
    global usuario_activo
    while True:
        try:
            # Se queda pausado aquí hasta que llegue un paquete UDP (Buffer de 1024 bytes)
            data, addr = sock_recibir.recvfrom(1024)
            
            # Decodificar el JSON entrante
            mensaje_json = json.loads(data.decode('utf-8'))
            
            print(f"\n\n📥 [RECIBIDO DESDE FLUTTER - {addr[0]}]:")
            
            # Caso 1: Cambio de usuario
            if mensaje_json.get("type") == "set_user":
                usuario_activo = mensaje_json.get("user")
                print(f"👤 PERFIL ACTUALIZADO -> Sincronizado con Usuario: {usuario_activo}")
            
            # Caso 2: Datos de calibración calculados por la App
            elif mensaje_json.get("type") == "calibrate":
                print(f"📐 NUEVA CALIBRACIÓN RECIBIDA PARA USUARIO {mensaje_json.get('user')}:")
                print(f"   ↳ Promedio Cráneo (Cervical): {mensaje_json.get('cervical'):.2f}°")
                print(f"   ↳ Promedio Cuello:            {mensaje_json.get('cuello'):.2f}°")
                print(f"   ↳ Promedio Espalda (Lumbar):  {mensaje_json.get('lumbar'):.2f}°")
                print("💾 Valores guardados con éxito en el 'hardware'.")
            
            print("\nIngresa comando (0, 1, 2, 3 o q): ", end="") # Re-imprime la línea de comando
            
        except Exception as e:
            print(f"\n❌ Error al procesar datos entrantes: {e}")

# Iniciamos ambos hilos en segundo plano
hilo_transmision = threading.Thread(target=enviar_datos, daemon=True)
hilo_transmision.start()

hilo_escucha = threading.Thread(target=escuchar_datos, daemon=True)
hilo_escucha.start()

# ==========================================
# MENÚ INTERACTIVO EN LA TERMINAL
# ==========================================
print("\n" + "="*40)
print(" 🚀 SIMULADOR ERGOALERT BIDIRECCIONAL")
print("="*40)
print(" 📢 Transmitiendo a celular por puerto 5005...")
print(" 🎧 Escuchando respuestas en puerto 5006...\n")
print("Escribe un número para cambiar la postura enviada:")
print("  [0] -> POSTURA PERFECTA (0°)")
print("  [1] -> ENCORVADO (Fallo en la Lumbar)")
print("  [2] -> CUELLO DE TEXTO (Mirando abajo)")
print("  [3] -> POSTURA EXTREMA (Todo mal)")
print("  [q] -> Salir")
print("="*40 + "\n")

while True:
    comando = input("Ingresa comando (0, 1, 2, 3 o q): ").strip().lower()
    
    if comando == '0':
        angulos_base = {"cervical": 0.0, "cuello": 0.0, "lumbar": 0.0}
        print("✅ Ajustado: POSTURA PERFECTA\n")
    elif comando == '1':
        angulos_base = {"cervical": 5.0, "cuello": 10.0, "lumbar": 35.0}
        print("⚠️ Ajustado: ENCORVADO\n")
    elif comando == '2':
        angulos_base = {"cervical": 45.0, "cuello": 25.0, "lumbar": 5.0}
        print("⚠️ Ajustado: CUELLO DE TEXTO\n")
    elif comando == '3':
        angulos_base = {"cervical": 50.0, "cuello": 40.0, "lumbar": 45.0}
        print("❌ Ajustado: POSTURA EXTREMA\n")
    elif comando == 'q':
        print("Apagando simulador...")
        break
    else:
        print("Comando no reconocido.\n")