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

  static const Color _primary = Color(0xFF3A1060);
  static const Color _purple = Color(0xFF6B2D8B);
  static const Color _purpleLight = Color(0xFF9C4DBC);
  static const Color _green = Color(0xFF7DC242);
  static const Color _greenDark = Color(0xFF4CAF50);
  static const Color _orange = Color(0xFFFF9800);
  static const Color _bg = Color(0xFFF4F0F8);

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
      sumX += x; sumY += y; sumXY += x * y; sumX2 += x * x;
    }
    double pendiente = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercepto = (sumY - pendiente * sumX) / n;
    return {'pendiente': pendiente, 'intercepto': intercepto};
  }

  Color _colorCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS': return _purple;
      case 'ACADÉMICOS': return const Color(0xFF2196F3);
      case 'TÁCTICOS': return _green;
      case 'OPERATIVOS': return _orange;
      default: return Colors.grey;
    }
  }

  IconData _iconCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS': return Icons.star_rounded;
      case 'ACADÉMICOS': return Icons.school_rounded;
      case 'TÁCTICOS': return Icons.military_tech_rounded;
      case 'OPERATIVOS': return Icons.settings_rounded;
      default: return Icons.circle;
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
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          _loading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator(color: _purple)))
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_rangos != null) ...[
                          _buildCostCards(),
                          const SizedBox(height: 16),
                          _buildRangosCard(),
                          const SizedBox(height: 16),
                        ],
                        _buildCurvaEquidadCard(),
                        const SizedBox(height: 16),
                        _buildMasaSalarialCard(),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _purple, _purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${widget.nombres.split(' ').first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Análisis Salarial',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('RR.HH.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostCards() {
    final costoActual = _toDouble(_rangos!['costo_actual']);
    final costoPropuesto = _toDouble(_rangos!['costo_propuesto']);
    final diferencia = costoPropuesto - costoActual;
    final incremento = _rangos!['incremento_promedio'];

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Costo Mensual',
            icon: Icons.payments_outlined,
            color: _purple,
            rows: [
              _SummaryRow('Escala 2024', _formatMoney(costoActual), _purple),
              _SummaryRow('Propuesta', _formatMoney(costoPropuesto), _green),
              _SummaryRow('Diferencia', '+${_formatMoney(diferencia)}', _green,
                  isBold: true),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Incremento Promedio',
            icon: Icons.trending_up_rounded,
            color: _green,
            rows: [
              _SummaryRow('Escala 2024', '0.0%', _purple),
              _SummaryRow('Propuesta', '$incremento%', _green),
              _SummaryRow('Diferencia', '+$incremento pts', _green,
                  isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_SummaryRow> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (final row in rows) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.label,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600)),
                Text(row.value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: row.isBold
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: row.color)),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }

  Widget _buildRangosCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _purple.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('Rangos Salariales Mín. y Máx.',
              Icons.compare_arrows_rounded, _purple),
          const SizedBox(height: 4),
          Text('Comparación de banda salarial por nivel: propuesto vs. actual (S/.)',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          _buildRangosChart(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _leyenda(const Color(0xFF6B2D8B), 'Actual - Mín.'),
              _leyenda(const Color(0xFF9B4DBB), 'Actual - Máx.'),
              _leyenda(const Color(0xFF7DC242), 'Propuesta - Mín.'),
              _leyenda(const Color(0xFF4CAF50), 'Propuesta - Máx.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurvaEquidadCard() {
    return _buildChartCard(
      title: 'Curva de Equidad',
      subtitle: 'Puntos de valoración vs. sueldo actual y esperado',
      icon: Icons.show_chart_rounded,
      color: _greenDark,
      chartHeight: 300,
      chart: _buildLineChart(),
      legend: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _leyenda(_greenDark, 'Salario Actual'),
          const SizedBox(width: 24),
          _leyenda(_orange, 'Salario Esperado'),
        ],
      ),
    );
  }

  Widget _buildMasaSalarialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _purple.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
              'Masa Salarial por Categoría', Icons.pie_chart_outline_rounded, _orange),
          const SizedBox(height: 16),
          for (final item in _data!['masa_salarial'] as List) ...[
            _buildMasaRow(item),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildMasaRow(dynamic item) {
    final color = _colorCategoria(item['categoria']);
    final icon = _iconCategoria(item['categoria']);
    final pct = _toDouble(item['porcentaje']);

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item['categoria'],
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _primary),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item['porcentaje']}%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 7,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double chartHeight,
    required Widget chart,
    required Widget legend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(title, icon, color),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          SizedBox(height: chartHeight, child: chart),
          const SizedBox(height: 12),
          legend,
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: _primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRangosChart() {
    if (_rangos == null) return const Center(child: Text('Sin datos'));
    final r = _rangos!['rangos'];
    if (r == null) return const Center(child: Text('Sin datos de rangos'));

    final factor = 1.045;
    final niveles = [
      {'label': 'JUNIOR', 'min': _toDouble(r['junior_min']), 'max': _toDouble(r['junior_max'])},
      {'label': 'SENIOR', 'min': _toDouble(r['senior_min']), 'max': _toDouble(r['senior_max'])},
      {'label': 'MASTER', 'min': _toDouble(r['master_min']), 'max': _toDouble(r['master_max'])},
    ];

    final allValues = niveles.expand((n) => [
      n['min'] as double,
      n['max'] as double,
      (n['min'] as double) * factor,
      (n['max'] as double) * factor,
    ]).toList();
    final maxVal = allValues.reduce((a, b) => a > b ? a : b) * 1.15;

    return Column(
      children: niveles.map((nivel) {
        final min = nivel['min'] as double;
        final max = nivel['max'] as double;
        final minProp = min * factor;
        final maxProp = max * factor;
        final label = nivel['label'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primary)),
              const SizedBox(height: 6),
              _buildBarRow('Actual', min, max, maxVal,
                  const Color(0xFF6B2D8B), const Color(0xFF9B4DBB)),
              const SizedBox(height: 4),
              _buildBarRow('Propuesta', minProp, maxProp, maxVal,
                  const Color(0xFF7DC242), const Color(0xFF4CAF50)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarRow(String tag, double min, double max, double maxVal,
      Color colorMin, Color colorMax) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth - 70;
      final minWidth = (min / maxVal * totalWidth).clamp(0.0, totalWidth);
      final maxWidth = (max / maxVal * totalWidth).clamp(0.0, totalWidth);

      return Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(tag,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 18,
                  width: maxWidth,
                  decoration: BoxDecoration(
                    color: colorMax.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 18,
                  width: minWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colorMin, colorMax]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Positioned(
                  left: 6, top: 0, bottom: 0,
                  child: Center(
                    child: Text(
                      _formatMoney(min),
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  left: maxWidth + 4, top: 0, bottom: 0,
                  child: Center(
                    child: Text(
                      _formatMoney(max),
                      style: TextStyle(
                          fontSize: 9,
                          color: colorMax,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLineChart() {
    final dispersion = _data!['dispersion'] as List;
    if (dispersion.isEmpty) return const Center(child: Text('Sin datos'));

    final sorted = List<dynamic>.from(dispersion)
      ..sort((a, b) =>
          _toDouble(a['puntos']).compareTo(_toDouble(b['puntos'])));

    final banda = _calcularBanda(sorted);
    final pendiente = banda['pendiente']!;
    final intercepto = banda['intercepto']!;

    final actualSpots = sorted
        .map((e) => FlSpot(_toDouble(e['puntos']), _toDouble(e['remuneracion'])))
        .toList();

    final esperadoSpots = sorted.map((e) {
      double x = _toDouble(e['puntos']);
      double y = (pendiente * x + intercepto).clamp(0.0, 15000.0);
      return FlSpot(x, y);
    }).toList();

    double maxX = sorted
        .map((e) => _toDouble(e['puntos']))
        .reduce((a, b) => a > b ? a : b);
    double maxY = sorted
        .map((e) => _toDouble(e['remuneracion']))
        .reduce((a, b) => a > b ? a : b);
    maxX = ((maxX / 100).ceil() * 100).toDouble();
    maxY = ((maxY / 1000).ceil() * 1000).toDouble();

    return LineChart(LineChartData(
      minX: 0, maxX: maxX, minY: 0, maxY: maxY,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (v) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        getDrawingVerticalLine: (v) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Colors.grey.shade200)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text('Salario (S/)',
                style: TextStyle(fontSize: 10, color: Colors.black54)),
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
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: actualSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: _greenDark,
          barWidth: 2.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
              show: true,
              color: _greenDark.withOpacity(0.07)),
        ),
        LineChartBarData(
          spots: esperadoSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: _orange,
          barWidth: 2.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
              show: true, color: _orange.withOpacity(0.07)),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final label =
                  spot.barIndex == 0 ? 'Actual' : 'Esperado';
              return LineTooltipItem(
                '$label: S/${spot.y.toInt()}\nPuntos: ${spot.x.toInt()}',
                TextStyle(
                  color: spot.barIndex == 0 ? _greenDark : _orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            }).toList();
          },
        ),
      ),
    ));
  }

  Widget _leyenda(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  const _SummaryRow(this.label, this.value, this.color,
      {this.isBold = false});
}