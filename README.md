# ErgoAlert: Sistema de Monitoreo Cinemático y Salud Vascular

## 📋 Análisis de Requerimientos

### Requerimientos Funcionales (RF)
* **RF1 - Adquisición Multi-Nodo:** Captura simultánea de 3 sensores MPU-6050 vía I2C (Cervical, Torácico, Lumbar).
* **RF2 - Fusión de Sensores:** Filtro complementario en RP2350 para cálculo de *Pitch* y *Roll* a 100 Hz.
* **RF3 - Calibración Biométrica:** Captura de postura neutra personalizada por usuario.
* **RF4 - Alertas Escalonadas:** Buzzer local (15s) y notificación Wi-Fi (60s) ante mala postura sostenida.
* **RF5 - Intervención Activa:** Visualización de ejercicios correctivos según la zona de falla detectada.

### Requerimientos No Funcionales (RNF)
* **RNF1 - Concurrencia:** Arquitectura *Dual-Core* (Core 1: Filtros | Core 0: Wi-Fi/Comunicaciones).
* **RNF2 - Precisión Angular:** Error máximo tolerable de $\pm 2^\circ$.
* **RNF3 - Latencia:** Respuesta del sistema inferior a 50 ms.
* **RNF4 - Autonomía:** Operación de 8 horas continuas con batería LiPo de 500 mAh.

---

## 🧪 Plan de Pruebas y Validación
1. **Validación Vascular:** Medición de $SpO_2$ y frecuencia cardíaca en postura colapsada vs. corregida.
2. **Inmunidad al Ruido:** Estabilidad del algoritmo ante movimientos cotidianos (evitar falsos positivos).
3. **Latencia Wi-Fi:** Tiempo de llegada de notificación remota (Meta: < 200 ms).
4. **Calibración:** Validación con diferentes anatomías para confirmar independencia de la estatura.

---

## 💰 Análisis de Costos y Viabilidad

### Presupuesto Detallado
| Categoría | Componente | Cantidad | Unitario (COP) | Total (COP) |
| :--- | :--- | :---: | :---: | :---: |
| **Hardware** | Raspberry Pi Pico 2 W | 1 | $75,000 | $75,000 |
| **Hardware** | MPU-6050 (IMU) | 3 | $18,000 | $54,000 |
| **Hardware** | Batería LiPo 3.7V | 1 | $25,000 | $25,000 |
| **Hardware** | Módulos de Potencia | 1 | $12,000 | $12,000 |
| **Hardware** | Buzzer / LED RGB | 1 | $5,500 | $5,500 |
| **Fabricación** | PCB Manufactura | 1 | $40,000 | $40,000 |
| **Fabricación** | Carcasa (Impresión 3D) | 3 | $20,000 | $60,000 |
| **Fabricación** | Cableado y Conectores | -- | $30,000 | $30,000 |
| **TOTAL** | | | | **$316,500** |

### Estrategia de Financiamiento
Los costos serán cubiertos mediante inversión equitativa del equipo. Se utilizará la infraestructura de laboratorios universitarios para el ensamble y validación con instrumentación profesional (Osciloscopio, Analizador Lógico).
