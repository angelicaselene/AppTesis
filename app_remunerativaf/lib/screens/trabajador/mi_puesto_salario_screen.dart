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
  List<dynamic> _historial = [];
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
    final historial = await ApiService.getHistorialRemuneracion();
    setState(() {
      _perfil = perfil;
      _valuacion = valuacion;
      _historial = historial;
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

  Color _colorBanda(String banda) {
    switch (banda) {
      case 'MASTER': return const Color(0xFF7DC242);
      case 'SENIOR': return const Color(0xFF6B2D8B);
      default: return Colors.orange;
    }
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

  List<FlSpot> _buildSpots() {
    if (_historial.isEmpty) return [FlSpot(0, 0)];
    final items = _historial.length > 6 ? _historial.sublist(_historial.length - 6) : _historial;
    return items.asMap().entries.map((e) {
      final rem = double.tryParse(e.value['remuneracion']?.toString() ?? '0') ?? 0;
      return FlSpot(e.key.toDouble(), rem);
    }).toList();
  }

  List<String> _buildLabels() {
    if (_historial.isEmpty) return [];
    final items = _historial.length > 6 ? _historial.sublist(_historial.length - 6) : _historial;
    return items.map((e) {
      final mes = (e['mes']?.toString() ?? '').substring(0, 3);
      final anio = e['anio']?.toString().substring(2) ?? '';
      return '$mes\n\'$anio';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];
    final puntos = _calcularPuntos();
    final banda = _calcularBanda(puntos);
    final salario = contrato?['remuneracion'] ?? '0.00';
    final colorBanda = _colorBanda(banda);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EDF5),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A1570), Color(0xFF6B2D8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Hola, ${_formatearNombre(widget.nombres)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!_loading) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            contrato?['cargo'] ?? 'Sin cargo',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorBanda.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            banda,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 3 métricas principales
                        Row(
                          children: [
                            Expanded(
                              child: _metricaCard(
                                'Salario Actual',
                                'S/ ${salario}',
                                Icons.payments_outlined,
                                const Color(0xFF7DC242),
                                const Color(0xFFEEF7E5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _metricaCard(
                                'Puntos',
                                '$puntos pts',
                                Icons.star_outline_rounded,
                                const Color(0xFF6B2D8B),
                                const Color(0xFFF0EDF5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _metricaCard(
                                'Categoría',
                                '${clasificacion?['nivel'] ?? 'N/A'}',
                                Icons.workspace_premium_outlined,
                                const Color(0xFF4A1570),
                                const Color(0xFFF0EDF5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card posicionamiento salarial
                        _sectionCard(
                          titulo: 'Posicionamiento en Banda $banda',
                          subtitulo: 'Tu salario vs rangos de la banda',
                          child: SizedBox(height: 210, child: _buildBarChart(salario, banda)),
                        ),
                        const SizedBox(height: 16),

                        // Card evolución salarial
                        _sectionCard(
                          titulo: 'Evolución Salarial',
                          subtitulo: 'Historial de tus remuneraciones',
                          child: _historial.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Text('Sin datos disponibles', style: TextStyle(color: Colors.black45)),
                                  ),
                                )
                              : SizedBox(height: 200, child: _buildLineChart()),
                        ),
                        const SizedBox(height: 16),

                        // Info departamento y contrato
                        _sectionCard(
                          titulo: 'Información del Contrato',
                          subtitulo: '',
                          child: Column(
                            children: [
                              _infoRow(Icons.business_outlined, 'Departamento', contrato?['departamento'] ?? 'N/A'),
                              const Divider(height: 20),
                              _infoRow(Icons.description_outlined, 'Tipo de Contrato', contrato?['tipo_contrato'] ?? 'N/A'),
                              const Divider(height: 20),
                              _infoRow(Icons.calendar_today_outlined, 'Fecha de Ingreso', contrato?['fecha_ingreso'] ?? 'N/A'),
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

  Widget _metricaCard(String label, String valor, IconData icono, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icono, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 2),
          Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _sectionCard({required String titulo, required String subtitulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D1040))),
          if (subtitulo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitulo, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icono, String label, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: const Color(0xFF6B2D8B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D1040))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(dynamic salario, String banda) {
    final salarioActual = double.tryParse(salario.toString()) ?? 0;
    double minimo, medio, maximo;
    switch (banda) {
      case 'MASTER': minimo = 5000; medio = 7000; maximo = 9000; break;
      case 'SENIOR': minimo = 3000; medio = 4500; maximo = 6000; break;
      default: minimo = 1000; medio = 2000; maximo = 3000;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maximo * 1.3,
        barGroups: [
          _barGroup(0, minimo, salarioActual),
          _barGroup(1, medio, salarioActual),
          _barGroup(2, maximo, salarioActual),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Text('S/${value.toInt()}', style: const TextStyle(fontSize: 9, color: Colors.black38)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Mínimo', 'Medio', 'Máximo'];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 11, color: Colors.black54)),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double rango, double salarioActual) {
    return BarChartGroupData(
      x: x,
      groupVertically: false,
      barRods: [
        BarChartRodData(toY: rango, color: const Color(0xFF7DC242), width: 18, borderRadius: BorderRadius.circular(6)),
        BarChartRodData(toY: salarioActual, color: const Color(0xFF6B2D8B), width: 18, borderRadius: BorderRadius.circular(6)),
      ],
      barsSpace: 6,
    );
  }

  Widget _buildLineChart() {
    final spots = _buildSpots();
    final labels = _buildLabels();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.25;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.85;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          getDrawingVerticalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return Text(labels[idx], textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.black45));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Text('S/${value.toInt()}', style: const TextStyle(fontSize: 9, color: Colors.black38)),
            ),
          ),
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
                strokeWidth: 2.5,
                strokeColor: const Color(0xFF6B2D8B),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B2D8B).withOpacity(0.2),
                  const Color(0xFF6B2D8B).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}