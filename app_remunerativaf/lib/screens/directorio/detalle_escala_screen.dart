import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/pdf_service.dart';

class DetalleEscalaScreen extends StatefulWidget {
  final String nombres;
  const DetalleEscalaScreen({super.key, required this.nombres});

  @override
  State<DetalleEscalaScreen> createState() => _DetalleEscalaScreenState();
}

class _DetalleEscalaScreenState extends State<DetalleEscalaScreen> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _analisis;
  Map<String, dynamic>? _rangos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await ApiService.getDetalleEscala();
    final analisis = await ApiService.getAnalisisSalarial();
    final rangos = await ApiService.getAnalisisRangos();
    setState(() {
      _data = data;
      _analisis = analisis;
      _rangos = rangos;
      _loading = false;
    });
  }

  double _toDouble(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0;
  }

  Color _colorFactor(String factor) {
    switch (factor.toUpperCase()) {
      case 'COMPETENCIAS': return const Color(0xFF2196F3);
      case 'ESFUERZO': return const Color(0xFFFF9800);
      case 'RESPONSABILIDAD': return const Color(0xFF4CAF50);
      case 'CONDICIONES TRAB.': return Colors.red;
      default: return Colors.grey;
    }
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
                        const Text(
                          'Detalle de Escala',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Análisis completo de la valuación de puestos y la equidad salarial de la versión aprobada.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Botón PDF
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_analisis != null &&
                                  _rangos != null &&
                                  _data != null) {
                                await PdfService.generarReporteAnalisis(
                                  analisis: _analisis!,
                                  rangos: _rangos!,
                                  detalleEscala: _data!,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B2D8B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: const Text(
                              'Descargar informe en PDF',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cards índice y brecha
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Índice de Equidad',
                                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_data!['indice_equidad']}%',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7DC242),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Brecha Salarial Máx.',
                                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_data!['brecha_salarial']}%',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7DC242),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Gráfico barras horizontales - Peso de Factores
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
                                'Análisis de Peso de Factores (Calibración)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              for (final item in _data!['pesos_factores'] as List) ...[
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        '${item['factor']}\n(${item['porcentaje']}%)',
                                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _toDouble(item['porcentaje']) / 100,
                                          minHeight: 20,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _colorFactor(item['factor']),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gráfico barras verticales - Distribución por Banda
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
                                'Distribución de Puestos por Banda Salarial',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Muestra cuántos puestos se agruparon en cada Nivel Remunerativo.',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 220,
                                child: _buildBarChart(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _leyenda(const Color(0xFF6B2D8B), 'Cantidad de Puestos'),
                                  const SizedBox(width: 16),
                                  _leyenda(const Color(0xFF7DC242), 'Score Promedio (Puntos)'),
                                ],
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

  Widget _buildBarChart() {
    final bandas = _data!['bandas'] as Map<String, dynamic>;
    final scores = _data!['score_promedio'] as Map<String, dynamic>;

    final labels = ['MASTER', 'SENIOR', 'JUNIOR'];
    final maxCantidad = labels.map((b) => _toDouble(bandas[b])).reduce((a, b) => a > b ? a : b);
    final maxScore = labels.map((b) => _toDouble(scores[b])).reduce((a, b) => a > b ? a : b);
    final maxY = (maxCantidad > maxScore ? maxCantidad : maxScore) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: labels.asMap().entries.map((e) {
          final banda = e.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: _toDouble(bandas[banda]),
                color: const Color(0xFF6B2D8B),
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: _toDouble(scores[banda]),
                color: const Color(0xFF7DC242),
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  labels[value.toInt()],
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
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

  Widget _leyenda(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}