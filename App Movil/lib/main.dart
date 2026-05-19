import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/posture_provider.dart';
import 'widgets/posture_avatar.dart';
import 'services/network_service.dart'; // <--- IMPORTAMOS TU NUEVO SERVICIO DE RED
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PostureProvider(),
      child: const ErgoAlertApp(),
    ),
  );
}

class ErgoAlertApp extends StatelessWidget {
  const ErgoAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ErgoAlert',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: Colors.greenAccent,
      ),
      home: const MainContainer(),
    );
  }
}

// Contenedor principal que controla las pestañas de navegación
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  int _activeUser = 1;

  List<Widget> get _pages => [
    const LiveViewPage(),
    CalibrationPage(activeUser: _activeUser),
    StatisticsPage(activeUser: _activeUser),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 10,
        centerTitle: false,
        title: const Text(
          "ERGOALERT",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _activeUser,
                dropdownColor: const Color(0xFF161B22),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.redAccent,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _activeUser = newValue;
                    });

                    // LLAMADA AL SERVICIO DE RED: Notificamos cambio de usuario a la Pi
                    NetworkService.sendActiveUser(newValue);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Raspberry sincronizada: Perfil de Usuario $_activeUser",
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                items: const [
                  DropdownMenuItem(value: 1, child: Text("USER 01")),
                  DropdownMenuItem(value: 2, child: Text("USER 02")),
                  DropdownMenuItem(value: 3, child: Text("USER 03")),
                  DropdownMenuItem(value: 4, child: Text("USER 04")),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'EN VIVO'),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: 'CALIBRAR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'ESTADÍSTICAS',
          ),
        ],
      ),
    );
  }
}

// --- ESCENA 1: MONITOREO EN VIVO ---
class LiveViewPage extends StatelessWidget {
  const LiveViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final posture = Provider.of<PostureProvider>(context);
    final data = posture.currentData;

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAngleCard("CRÁNEO", data?.cervical),
            _buildAngleCard("CUELLO", data?.cuello),
            _buildAngleCard("ESPALDA", data?.lumbar),
          ],
        ),
        const Spacer(),
        if (data != null)
          PostureAvatar(
            cervical: data.cervical,
            cuello: data.cuello,
            lumbar: data.lumbar,
          )
        else
          const CircularProgressIndicator(color: Colors.greenAccent),
        const Spacer(),
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            color: (data != null && (data.cervical.abs() > 20))
                ? Colors.red.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: (data != null && (data.cervical.abs() > 20))
                  ? Colors.red
                  : Colors.greenAccent,
            ),
          ),
          child: Text(
            data == null
                ? "SIN SEÑAL"
                : (data.cervical.abs() > 20
                      ? "¡CORRIGE TU POSTURA!"
                      : "POSTURA EXCELENTE"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAngleCard(String label, double? val) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            "${val?.toStringAsFixed(1) ?? '0'}°",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// --- ESCENA 2: CALIBRACIÓN INTERACTIVA MULTIUSUARIO ---
class CalibrationPage extends StatefulWidget {
  final int activeUser;

  const CalibrationPage({super.key, required this.activeUser});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  int _step = 0;
  int _countdown = 3;
  bool _isCountingDown = false;
  Timer? _timer;

  List<double> _capturedCervical = [];
  List<double> _capturedCuello = [];
  List<double> _capturedLumbar = [];

  final List<String> _instructions = [
    "APOYA TU ESPALDA BAJA\n SOBRE LA SILLA\n(ZONA LUMBAR)",
    "RELAJA LOS HOMBROS\n(ZONA C7)",
    "RETRAE EL MENTÓN\n(ZONA CRANEAL)",
  ];

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() => _isCountingDown = false);
      }
    });
  }

  void _captureAndNext(double c, double n, double l) {
    _capturedCervical.add(c);
    _capturedCuello.add(n);
    _capturedLumbar.add(l);

    if (_step < 3) {
      setState(() => _step++);
      _startCountdown();
    } else {
      setState(() => _step = 4);

      // LLAMADA AL SERVICIO DE RED: Despachamos los vectores para promediar en hardware
      NetworkService.sendCalibration(
        user: widget.activeUser,
        cervicalList: _capturedCervical,
        cuelloList: _capturedCuello,
        lumbarList: _capturedLumbar,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _step = 0;
            _capturedCervical.clear();
            _capturedCuello.clear();
            _capturedLumbar.clear();
          });
        }
      });
    }
  }

  bool _isPostureValid(double val) {
    return val.abs() < 8.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posture = Provider.of<PostureProvider>(context);
    final data = posture.currentData;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A0A0A),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_step == 0) _buildIntro(),
          if (_step > 0 && _step <= 3 && _isCountingDown) _buildCountdown(),
          if (_step > 0 && _step <= 3 && !_isCountingDown)
            _buildLiveCalibration(data),
          if (_step == 4) _buildSuccess(),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Text(
          "PROTOCOLO DE CALIBRACIÓN\n(USUARIO ${widget.activeUser})",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.redAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Para un diagnóstico profesional, calcularemos tu 'Postura Ideal' promediando 3 tomas estables.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() => _step = 1);
            _startCountdown();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
          child: const Text(
            "INICIAR OPTIMIZACIÓN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Column(
      children: [
        Text(
          _instructions[_step - 1],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 50),
        Text(
          "$_countdown",
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: Colors.redAccent,
          ),
        ),
        const Text(
          "PREPÁRATE...",
          style: TextStyle(letterSpacing: 5, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLiveCalibration(dynamic data) {
    double currentVal = 0;
    if (_step == 1) currentVal = data?.lumbar ?? 100;
    if (_step == 2) currentVal = data?.cuello ?? 100;
    if (_step == 3) currentVal = data?.cervical ?? 100;

    bool valid = _isPostureValid(currentVal);

    return Column(
      children: [
        Text(
          "PASO $_step DE 3",
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _instructions[_step - 1],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 120),
        SizedBox(
          height: 250,
          child: data != null
              ? PostureAvatar(
                  cervical: data.cervical,
                  cuello: data.cuello,
                  lumbar: data.lumbar,
                )
              : const CircularProgressIndicator(),
        ),
        const SizedBox(height: 20),
        Text(
          valid
              ? "POSICIÓN CORRECTA"
              : "AJUSTA TU POSICIÓN HASTA ALINEAR EL SENSOR",
          style: TextStyle(
            color: valid ? Colors.greenAccent : Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: valid
                  ? () => _captureAndNext(
                      data!.cervical,
                      data.cuello,
                      data.lumbar,
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: valid ? Colors.green : Colors.white10,
              ),
              child: const Text("ESTABLECER"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const Icon(Icons.verified, size: 80, color: Colors.greenAccent),
        const SizedBox(height: 20),
        const Text(
          "CALIBRACIÓN EXITOSA",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "VALORES GUARDADOS EN RASPBERRY:",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Text(
          "C: ${_capturedCervical.isNotEmpty ? _capturedCervical.last.toStringAsFixed(1) : '0'}°  |  N: ${_capturedCuello.isNotEmpty ? _capturedCuello.last.toStringAsFixed(1) : '0'}°  |  L: ${_capturedLumbar.isNotEmpty ? _capturedLumbar.last.toStringAsFixed(1) : '0'}°",
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ESTADISTICAS EN TIEMPO REAL (ESCENA 3)

class StatisticsPage extends StatefulWidget {
  final int activeUser; // <--- Recibimos el usuario como parámetro

  const StatisticsPage({super.key, required this.activeUser});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isDayView = true;

  @override
  void initState() {
    super.initState();
    // Al abrir la pantalla, pedimos los datos de HOY usando el activeUser que pasaste
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkService.requestLiveStatistics(widget.activeUser, "hoy");
    });
  }

  // Función para pedir datos cuando cambias de Pestaña (Hoy/Semana)
  void _toggleView(bool isDay) {
    setState(() => _isDayView = isDay);
    String viewMode = isDay ? "hoy" : "semana";

    // Usamos widget.activeUser para la petición
    NetworkService.requestLiveStatistics(widget.activeUser, viewMode);
  }

  // Convertidor matemático: Convierte 310 minutos a "5h 10m"
  String _formatTime(int totalMinutes) {
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    if (h == 0) return "${m}m";
    return "${h}h ${m}m";
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para redibujar la pantalla
    final provider = context.watch<PostureProvider>();

    // Cálculos para las barras de progreso
    int totalTime =
        provider.statSaludableMin +
        provider.statMalaMin +
        provider.statCriticaMin;
    double pctSaludable = totalTime > 0
        ? provider.statSaludableMin / totalTime
        : 0.0;
    double pctMala = totalTime > 0 ? provider.statMalaMin / totalTime : 0.0;
    double pctCritica = totalTime > 0
        ? provider.statCriticaMin / totalTime
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostramos de quién son estas estadísticas sutilmente
          Text(
            "Mostrando métricas del Usuario ${widget.activeUser}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),

          // TABS DE TIEMPO (Hoy / Semana)
          _buildTimeToggle(),
          const SizedBox(height: 30),

          // TARJETA PRINCIPAL
          _buildMainScoreCard(provider, totalTime),
          const SizedBox(height: 20),

          // BARRAS DE TIEMPO
          const Text(
            "DESGLOSE DE TIEMPO",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildTimeBreakdown(provider, pctSaludable, pctMala, pctCritica),
          const SizedBox(height: 20),

          // ALARMAS
          const Text(
            "INTERVENCIONES",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildAlarmsCard(provider),
        ],
      ),
    );
  }

  // =========================================
  // WIDGETS INTERNOS DE LA PANTALLA
  // =========================================

  Widget _buildTimeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleView(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isDayView
                      ? Colors.blueAccent.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  "HOY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDayView ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleView(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isDayView
                      ? Colors.blueAccent.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  "SEMANA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_isDayView ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScoreCard(PostureProvider provider, int totalTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161B22), Color(0xFF1A2332)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Índice de Salud",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "${provider.statScore}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const Text(
                    "%",
                    style: TextStyle(fontSize: 20, color: Colors.greenAccent),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Tiempo medido: ${_formatTime(totalTime)}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Icon(
            Icons.health_and_safety,
            size: 60,
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBreakdown(
    PostureProvider provider,
    double pSaludable,
    double pMala,
    double pCritica,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStatRow(
            "Postura Saludable",
            _formatTime(provider.statSaludableMin),
            pSaludable,
            Colors.greenAccent,
          ),
          const SizedBox(height: 15),
          _buildStatRow(
            "Postura Mala",
            _formatTime(provider.statMalaMin),
            pMala,
            Colors.orangeAccent,
          ),
          const SizedBox(height: 15),
          _buildStatRow(
            "Postura Crítica",
            _formatTime(provider.statCriticaMin),
            pCritica,
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String time,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFF0D1117),
            color: color,
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmsCard(PostureProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vibration,
              color: Colors.redAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Correcciones Activas",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Veces que se activó la alarma",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "${provider.statAlarmas}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
