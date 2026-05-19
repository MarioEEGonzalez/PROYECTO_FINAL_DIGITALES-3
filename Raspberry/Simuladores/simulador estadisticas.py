import socket
import json

# ==========================================
# CONFIGURACIÓN DE RED
# ==========================================
UDP_IP_CELULAR = "192.168.1.50"  # <--- RECUERDA PONER LA IP DE TU CELULAR
UDP_PORT_CELULAR = 5005
UDP_IP_ESCUCHA = "0.0.0.0"  
UDP_PORT_ESCUCHA = 5006  

sock_enviar = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_recibir = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_recibir.bind((UDP_IP_ESCUCHA, UDP_PORT_ESCUCHA))

# ==========================================
# BASE DE DATOS FIJA (MOCK DATA)
# Tiempos expresados en MINUTOS
# ==========================================
BASE_DE_DATOS = {
    1: { # 👤 DATOS DEL USUARIO 1 (El oficinista aplicado)
        "hoy": {"score": 85, "saludable_min": 310, "mala_min": 45, "critica_min": 25, "alarmas": 14},
        "semana": {"score": 82, "saludable_min": 1820, "mala_min": 320, "critica_min": 140, "alarmas": 65}
    },
    2: { # 👤 DATOS DEL USUARIO 2 (El gamer encorvado)
        "hoy": {"score": 45, "saludable_min": 120, "mala_min": 200, "critica_min": 90, "alarmas": 58},
        "semana": {"score": 50, "saludable_min": 850, "mala_min": 1200, "critica_min": 500, "alarmas": 210}
    },
    3: { # 👤 DATOS DEL USUARIO 3 (Postura perfecta)
        "hoy": {"score": 98, "saludable_min": 400, "mala_min": 10, "critica_min": 0, "alarmas": 2},
        "semana": {"score": 96, "saludable_min": 2200, "mala_min": 80, "critica_min": 5, "alarmas": 12}
    }
}

print("\n" + "="*50)
print(" 📊 MOCK SERVER DE ESTADÍSTICAS INICIADO")
print("="*50)
print("Esperando peticiones de Flutter en el puerto 5006...\n")

while True:
    try:
        # 1. Esperamos a que Flutter nos hable
        data, addr = sock_recibir.recvfrom(1024)
        peticion = json.loads(data.decode('utf-8'))
        
        # 2. Verificamos que sea una petición de estadísticas
        if peticion.get("type") == "request_stats":
            usuario_id = peticion.get("user", 1)  # Por defecto busca el 1 si no lo envían
            vista_tiempo = peticion.get("view", "hoy") # Puede ser "hoy" o "semana"
            
            print(f"📥 Petición recibida -> Usuario: {usuario_id} | Vista: {vista_tiempo}")
            
            # 3. Buscamos los datos en nuestra "Base de datos" de arriba
            # Si piden un usuario que no existe (ej. 4), le mandamos los datos del usuario 1
            datos_usuario = BASE_DE_DATOS.get(usuario_id, BASE_DE_DATOS[1])
            datos_respuesta = datos_usuario.get(vista_tiempo, datos_usuario["hoy"])
            
            # 4. Empaquetamos la respuesta agregando el tipo de paquete
            respuesta_json = {
                "type": "stats_response",
                "user": usuario_id,
                "view": vista_tiempo,
                "data": datos_respuesta
            }
            
            # 5. Se lo disparamos de vuelta al celular
            sock_enviar.sendto(json.dumps(respuesta_json).encode('utf-8'), (UDP_IP_CELULAR, UDP_PORT_CELULAR))
            print(f"📤 Respondido con éxito: {respuesta_json['data']}\n")
            
    except Exception as e:
        print(f"❌ Error en el servidor mock: {e}")