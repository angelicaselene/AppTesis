import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

class AnalisisSalarialScreen extends StatefulWidget {
  final String nombres;
  const AnalisisSalarialScreen({super.key, required this.nombres});

  @override
  State<AnalisisSalarialScreen> createState() => _AnalisisSalarialScreenState();
}

class _AnalisisSalarialScreenState extends State<AnalisisSalarialScreen> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _rangos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await ApiService.getAnalisisSalarial();
    final rangos = await ApiService.getAnalisisRangos();
    setState(() {
      _data = data;
      _rangos = rangos;
      _loading = false;
    });
  }

  Map<String, double> _calcularBanda(List<dynamic> dispersion) {
    if (dispersion.isEmpty) return {'pendiente': 0, 'intercepto': 0};
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = dispersion.length;
    for (final p in dispersion) {
      double x = (p['puntos'] as num?)?.toDouble() ?? 0;
      double y = (p['remuneracion'] as num?)?.toDouble() ?? 0;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    double pendiente = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercepto = (sumY - pendiente * sumX) / n;
    return {'pendiente': pendiente, 'intercepto': intercepto};
  }

  Color _colorCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS': return const Color(0xFF6B2D8B);
      case 'ACADÉMICOS': return const Color(0xFF2196F3);
      case 'TÁCTICOS': return const Color(0xFF7DC242);
      case 'OPERATIVOS': return const Color(0xFFFF9800);
      default: return Colors.grey;
    }
  }

  String _formatMoney(dynamic valor) {
    if (valor == null) return 'S/0';
    final num v = valor is num ? valor : num.tryParse(valor.toString()) ?? 0;
    if (v >= 1000000) return 'S/${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'S/${(v / 1000).toStringAsFixed(0)}K';
    return 'S/${v.toStringAsFixed(0)}';
  }

  double _toDouble(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
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
                  'Hola ${widget.nombres.split(' ').last}',
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
                        if (_rangos != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Costo Mensual (Total)',
                                          style: TextStyle(fontSize: 11, color: Colors.black54)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(children: [
                                            const Text('Escala 2024\n(Aprobada)',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                            Text(
                                              _formatMoney(_rangos!['costo_actual']),
                                              style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold,
                                                color: Color(0xFF6B2D8B),
                                              ),
                                            ),
                                          ]),
                                          Column(children: [
                                            const Text('Propuesta\n(RR.HH.)',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                            Text(
                                              _formatMoney(_rangos!['costo_propuesto']),
                                              style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold,
                                                color: Color(0xFF7DC242),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Diferencia Neta',
                                              style: TextStyle(fontSize: 11, color: Colors.black54)),
                                          Text(
                                            '+${_formatMoney(_toDouble(_rangos!['costo_propuesto']) - _toDouble(_rangos!['costo_actual']))}',
                                            style: const TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.bold,
                                              color: Color(0xFF7DC242),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Incremento Salarial Promedio',
                                          style: TextStyle(fontSize: 11, color: Colors.black54)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(children: [
                                            const Text('Escala 2024\n(Aprobada)',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                            const Text('0.0%',
                                                style: TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.bold,
                                                  color: Color(0xFF6B2D8B),
                                                )),
                                          ]),
                                          Column(children: [
                                            const Text('Propuesta\n(RR.HH.)',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                            Text(
                                              '${_rangos!['incremento_promedio']}%',
                                              style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold,
                                                color: Color(0xFF7DC242),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Diferencia Neta',
                                              style: TextStyle(fontSize: 11, color: Colors.black54)),
                                          Text(
                                            '+${_rangos!['incremento_promedio']} pts',
                                            style: const TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.bold,
                                              color: Color(0xFF7DC242),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Comparación: Rangos Salariales Mín. y Máx.',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Visualización del incremento de la banda salarial por nivel propuesto vs. actual (Soles).',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(height: 220, child: _buildRangosChart()),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    _leyenda(const Color(0xFF6B2D8B), 'Actual - Mínimo'),
                                    _leyenda(const Color(0xFF9B4DBB), 'Actual - Máximo'),
                                    _leyenda(const Color(0xFF7DC242), 'Propuesta - Mínimo'),
                                    _leyenda(const Color(0xFF4CAF50), 'Propuesta - Máximo'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Curva de Equidad (Puntos vs. Sueldo)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Comparación entre salario actual y salario esperado.',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(height: 300, child: _buildLineChart()),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _leyenda(const Color(0xFF4CAF50), 'Salario Actual'),
                                  const SizedBox(width: 24),
                                  _leyenda(const Color(0xFFFF9800), 'Salario Esperado'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Masa Salarial por Categoria',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              for (final item in _data!['masa_salarial'] as List) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['categoria'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      '${item['porcentaje']}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _colorCategoria(item['categoria']),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _toDouble(item['porcentaje']) / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _colorCategoria(item['categoria']),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
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

  Widget _buildRangosChart() {
    if (_rangos == null) return const Center(child: Text('Sin datos'));
    final r = _rangos!['rangos'];
    if (r == null) return const Center(child: Text('Sin datos de rangos'));

    final juniorMin = _toDouble(r['junior_min']);
    final juniorMax = _toDouble(r['junior_max']);
    final seniorMin = _toDouble(r['senior_min']);
    final seniorMax = _toDouble(r['senior_max']);
    final masterMin = _toDouble(r['master_min']);
    final masterMax = _toDouble(r['master_max']);

    final factor = 1.045;
    final maxY = masterMax * factor * 1.1 == 0 ? 10000.0 : masterMax * factor * 1.1;

    return LineChart(
      LineChartData(
        minX: 0, maxX: 2, minY: 0, maxY: maxY,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                const labels = ['JUNIOR', 'SENIOR', 'MASTER'];
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Text(labels[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Colors.black54));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [FlSpot(0, juniorMin), FlSpot(1, seniorMin), FlSpot(2, masterMin)],
            isCurved: false,
            color: const Color(0xFF6B2D8B),
            barWidth: 2,
            dotData: FlDotData(show: true),
            dashArray: [5, 3],
          ),
          LineChartBarData(
            spots: [FlSpot(0, juniorMax), FlSpot(1, seniorMax), FlSpot(2, masterMax)],
            isCurved: false,
            color: const Color(0xFF9B4DBB),
            barWidth: 2,
            dotData: FlDotData(show: true),
            dashArray: [5, 3],
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, juniorMin * factor),
              FlSpot(1, seniorMin * factor),
              FlSpot(2, masterMin * factor),
            ],
            isCurved: false,
            color: const Color(0xFF7DC242),
            barWidth: 2.5,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, juniorMax * factor),
              FlSpot(1, seniorMax * factor),
              FlSpot(2, masterMax * factor),
            ],
            isCurved: false,
            color: const Color(0xFF4CAF50),
            barWidth: 2.5,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final dispersion = _data!['dispersion'] as List;
    if (dispersion.isEmpty) return const Center(child: Text('Sin datos'));

    final sorted = List<dynamic>.from(dispersion)
      ..sort((a, b) => _toDouble(a['puntos']).compareTo(_toDouble(b['puntos'])));

    final banda = _calcularBanda(sorted);
    final pendiente = banda['pendiente']!;
    final intercepto = banda['intercepto']!;

    final actualSpots = sorted.map((e) {
      return FlSpot(_toDouble(e['puntos']), _toDouble(e['remuneracion']));
    }).toList();

    final esperadoSpots = sorted.map((e) {
      double x = _toDouble(e['puntos']);
      double y = (pendiente * x + intercepto).clamp(0.0, 15000.0);
      return FlSpot(x, y);
    }).toList();

    double maxX = sorted.map((e) => _toDouble(e['puntos'])).reduce((a, b) => a > b ? a : b);
    double maxY = sorted.map((e) => _toDouble(e['remuneracion'])).reduce((a, b) => a > b ? a : b);
    maxX = ((maxX / 100).ceil() * 100).toDouble();
    maxY = ((maxY / 1000).ceil() * 1000).toDouble();

    return LineChart(
      LineChartData(
        minX: 0, maxX: maxX, minY: 0, maxY: maxY,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text('Salario (S/)', style: TextStyle(fontSize: 10, color: Colors.black54)),
            ),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Valoración (Puntos)',
                style: TextStyle(fontSize: 10, color: Colors.black54)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxX / 5,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: actualSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFF4CAF50),
            barWidth: 2.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF4CAF50).withOpacity(0.05)),
          ),
          LineChartBarData(
            spots: esperadoSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFFFF9800),
            barWidth: 2.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFFFF9800).withOpacity(0.05)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final label = spot.barIndex == 0 ? 'Actual' : 'Esperado';
                return LineTooltipItem(
                  '$label: S/${spot.y.toInt()}\nPuntos: ${spot.x.toInt()}',
                  TextStyle(
                    color: spot.barIndex == 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _leyenda(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}