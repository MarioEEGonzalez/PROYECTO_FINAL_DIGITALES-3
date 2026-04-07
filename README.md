# PROYECTO_FINAL_DIGITALES-3
Proyecto final de la materia Sistemas digitales 3, contiene la informacion y codigos necesarios para implementar  un dispositivo biomedico capaz establecer una higiene postural.
\section{Descripción del Problema}
El aumento del trabajo sedentario y el uso prolongado de dispositivos electrónicos ha derivado en una crisis de salud ergonómica global. El cuerpo humano no está diseñado para mantener posiciones estáticas durante periodos extensos, lo que genera dos problemas críticos interconectados:

\begin{itemize}
    \item \textbf{Degradación Biomecánica:} La postura ``colapsada'' somete a la columna vertebral a cargas mecánicas desproporcionadas. Una inclinación cervical de $60^\circ$ ejerce una presión de hasta $27$ kg sobre las vértebras, provocando hipercifosis, hernias discales y el síndrome de \textit{Tech-Neck}.
    \item \textbf{Compromiso Vascular y Metabólico:} El estatismo postural prolongado comprime los vasos sanguíneos principales y reduce la eficiencia del retorno venoso. Esto disminuye la perfusión periférica y la oxigenación cerebral, afectando el rendimiento cognitivo y la salud cardiovascular a largo plazo.
\end{itemize}

\textbf{ErgoAlert} busca cerrar la brecha tecnológica actual mediante un sistema de tres nodos inerciales que analizan la cadena cinemática completa, permitiendo una calibración personalizada y una intervención activa mediante ejercicios sugeridos vía Wi-Fi.

\section{Análisis de Costos y Presupuesto}
El análisis de costos iniciales es fundamental para evaluar la viabilidad económica del sistema \textbf{ErgoAlert}. A continuación, se detallan los gastos previstos para el desarrollo del prototipo funcional.

\subsection{Hardware y Componentes Principales}
\begin{table}[h!]
\centering
\begin{tabular}{|l|c|r|r|}
\hline
\textbf{Componente} & \textbf{Cantidad} & \textbf{V. Unitario (COP)} & \textbf{Total (COP)} \\ \hline
Raspberry Pi Pico 2 W & 1 & \$75,000 & \$75,000 \\ \hline
Sensores MPU-6050 & 3 & \$18,000 & \$54,000 \\ \hline
Batería LiPo 3.7V 500mAh & 1 & \$25,000 & \$25,000 \\ \hline
Módulo de carga y elevador & 1 & \$12,000 & \$12,000 \\ \hline
Buzzer Activo y LED RGB & 1 & \$5,500 & \$5,500 \\ \hline
Multiplexor I2C TCA9548A & 1 & \$15,000 & \$15,000 \\ \hline
\multicolumn{3}{|l|}{\textbf{Subtotal Hardware}} & \textbf{\$186,500} \\ \hline
\end{tabular}
\caption{Costos de componentes electrónicos.}
\end{table}

\subsection{Diseño, Prototipado y Herramientas}
\begin{itemize}
    \item \textbf{Fabricación de PCB:} \$120,000 (Manufactura profesional en fibra de vidrio).
    \item \textbf{Carcasa e Impresión 3D:} \$60,000 (Diseño ergonómico para los 3 nodos).
    \item \textbf{Insumos y Cableado:} \$55,000 (Cables flexibles, soldadura y conectores).
\end{itemize}

\subsection{Resumen de Inversión}
El costo total estimado para la implementación del prototipo es de \textbf{\$421,500 COP}.

\section{Estrategia de Cobertura de Costos}
Para garantizar la ejecución del proyecto, se han definido las siguientes fuentes de financiamiento y optimización de recursos:
\begin{enumerate}
    \item \textbf{Financiamiento Directo:} El costo total será cubierto de forma equitativa por los integrantes del equipo.
    \item \textbf{Infraestructura Universitaria:} Se reducirán gastos operativos utilizando las estaciones de soldadura, osciloscopios y herramientas de diseño (Altium Designer) disponibles en los laboratorios de la institución.
    \item \textbf{Validación de Concepto:} El costo se justifica por el uso del microcontrolador RP2350, que permite el procesamiento concurrente de filtros de fusión de sensores y la gestión de la pila TCP/IP, capacidades superiores a las de correctores posturales comerciales de bajo costo.
\end{enumerate}
