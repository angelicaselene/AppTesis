import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

class MiPuestoSalarioScreen extends StatefulWidget {
  final String nombres;
  const MiPuestoSalarioScreen({super.key, required this.nombres});

  @override
  State<MiPuestoSalarioScreen> createState() => _MiPuestoSalarioScreenState();
}

class _MiPuestoSalarioScreenState extends State<MiPuestoSalarioScreen> {
  Map<String, dynamic>? _perfil;
  Map<String, dynamic>? _valuacion;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final perfil = await ApiService.getPerfil();
    Map<String, dynamic>? valuacion;
    if (perfil['id'] != null) {
      valuacion = await ApiService.getValuacion(perfil['id']);
    }
    setState(() {
      _perfil = perfil;
      _valuacion = valuacion;
      _loading = false;
    });
  }

  int _calcularPuntos() {
    if (_valuacion == null) return 0;
    final campos = [
      'formacion_profesional', 'investigacion', 'experiencia',
      'excelencia_servicio', 'capacidad_resolutiva', 'emprendimiento',
      'innovacion', 'competencia_digital', 'mental', 'emocional',
      'fisico', 'cumplimiento_metas', 'responsabilidades_financieras',
      'prestacion_servicios', 'confidencialidad', 'manejo_materiales',
      'manejo_personas', 'riesgo_ambiental', 'riesgo_psicologico',
    ];
    return campos.fold(0, (sum, c) => sum + ((_valuacion![c] ?? 0) as num).toInt());
  }

  String _calcularBanda(int puntos) {
    if (puntos >= 700) return 'MASTER';
    if (puntos >= 400) return 'SENIOR';
    return 'JUNIOR';
  }

  String _formatearNombre(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.length >= 3) {
      final nombre = partes[2][0].toUpperCase() + partes[2].substring(1).toLowerCase();
      final apellido = partes[0][0].toUpperCase() + partes[0].substring(1).toLowerCase();
      return '$nombre $apellido';
    }
    return nombreCompleto;
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];
    final puntos = _calcularPuntos();
    final banda = _calcularBanda(puntos);
    final salario = contrato?['remuneracion'] ?? '0.00';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6B2D8B),
            padding: const EdgeInsets.only(
              top: 50, left: 20, right: 20, bottom: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Hola, ${_formatearNombre(widget.nombres)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card puesto actual
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Puesto Actual',
                                  style: TextStyle(
                                    color: Color(0xFF7DC242),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                contrato?['cargo'] ?? 'Sin cargo',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Categoría: ${clasificacion?['categoria'] ?? 'N/A'} - ${clasificacion?['perfil'] ?? ''} ${clasificacion?['nivel'] ?? ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4 cards info
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                Icons.work_outline,
                                'Puesto Actual',
                                contrato?['cargo'] ?? 'N/A',
                                const Color(0xFF6B2D8B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                Icons.track_changes_outlined,
                                'Valor del Puesto (Puntos)',
                                'Puntos $puntos',
                                const Color(0xFF6B2D8B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                Icons.attach_money,
                                'Salario Actual (S/)',
                                'S/ $salario',
                                const Color(0xFF7DC242),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                Icons.trending_up,
                                'Banda Salarial',
                                banda,
                                const Color(0xFF6B2D8B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Gráfico posicionamiento salarial
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Posicionamiento Salarial en mi Banda ($banda)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Compara tu salario actual con los rangos Mínimo, Medio y Máximo de tu banda.',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 220,
                                child: _buildBarChart(salario, banda),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gráfico evolución salarial
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Evolución Salarial',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: _buildLineChart(salario),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icono, String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(dynamic salario, String banda) {
    final salarioActual = double.tryParse(salario.toString()) ?? 0;

    // Rangos estimados por banda
    double minimo, medio, maximo;
    switch (banda) {
      case 'MASTER':
        minimo = 5000; medio = 7000; maximo = 9000;
        break;
      case 'SENIOR':
        minimo = 3000; medio = 4500; maximo = 6000;
        break;
      default:
        minimo = 1000; medio = 2000; maximo = 3000;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maximo * 1.3,
        barGroups: [
          _barGroup(0, minimo, salarioActual, 'Mínimo'),
          _barGroup(1, medio, salarioActual, 'Medio'),
          _barGroup(2, maximo, salarioActual, 'Máximo'),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                'S/${value.toInt()}',
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Mínimo', 'Medio', 'Máximo'];
                return Text(
                  labels[value.toInt()],
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double rango, double salarioActual, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: rango,
          color: const Color(0xFF7DC242),
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: salarioActual,
          color: Colors.black87,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLineChart(dynamic salario) {
    final salarioActual = double.tryParse(salario.toString()) ?? 0;
    final spots = [
      FlSpot(0, salarioActual * 0.7),
      FlSpot(1, salarioActual * 0.8),
      FlSpot(2, salarioActual * 0.9),
      FlSpot(3, salarioActual),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 3,
        minY: 0,
        maxY: salarioActual * 1.2,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const years = ['2022', '2023', '2024', '2025'];
                return Text(
                  years[value.toInt()],
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6B2D8B),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF6B2D8B),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6B2D8B).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}