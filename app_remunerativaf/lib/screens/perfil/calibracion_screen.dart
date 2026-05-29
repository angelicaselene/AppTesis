import 'package:flutter/material.dart';

class CalibracionScreen extends StatelessWidget {
  final String nombres;
  const CalibracionScreen({super.key, required this.nombres});

  static const List<Map<String, dynamic>> _factores = [
    {
      'factor': 'COMPETENCIAS',
      'porcentaje': '50%',
      'subfactores': [
        {'nombre': 'Formación Profesional', 'pct': '10%', 'pts': 100, 'grados': [20, 40, 60, 80, 100], 'var': 20},
        {'nombre': 'Investigación', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Experiencia', 'pct': '10%', 'pts': 100, 'grados': [20, 40, 60, 80, 100], 'var': 20},
        {'nombre': 'Excelencia de servicio y atención al cliente', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Capacidad resolutiva', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Emprendimiento', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Innovación', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Competencia Digital', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
      ],
    },
    {
      'factor': 'ESFUERZO',
      'porcentaje': '15%',
      'subfactores': [
        {'nombre': 'Mental', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Emocional', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Físico', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
      ],
    },
    {
      'factor': 'RESPONSABILIDAD',
      'porcentaje': '30%',
      'subfactores': [
        {'nombre': 'Cumplimiento de metas', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Responsabilidades financieras', 'pct': '6%', 'pts': 60, 'grados': [12, 24, 36, 48, 60], 'var': 12},
        {'nombre': 'Prestación de servicios', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Confidencialidad', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
        {'nombre': 'Manejo de materiales, financieros y tecnológicos', 'pct': '4%', 'pts': 40, 'grados': [8, 16, 24, 32, 40], 'var': 8},
        {'nombre': 'Manejo de personas', 'pct': '5%', 'pts': 50, 'grados': [10, 20, 30, 40, 50], 'var': 10},
      ],
    },
    {
      'factor': 'CONDICIONES DE TRABAJO',
      'porcentaje': '5%',
      'subfactores': [
        {'nombre': 'Físico - Riesgos ambientales', 'pct': '2%', 'pts': 20, 'grados': [4, 8, 12, 16, 20], 'var': 4},
        {'nombre': 'Riesgo psicológicos', 'pct': '3%', 'pts': 30, 'grados': [6, 12, 18, 24, 30], 'var': 6},
      ],
    },
  ];

  Color _colorFactor(String factor) {
    switch (factor) {
      case 'COMPETENCIAS':        return const Color(0xFF6B2D8B);
      case 'ESFUERZO':            return const Color(0xFF2196F3);
      case 'RESPONSABILIDAD':     return const Color(0xFF7DC242);
      case 'CONDICIONES DE TRABAJO': return const Color(0xFFFF9800);
      default:                    return Colors.grey;
    }
  }

  IconData _iconFactor(String factor) {
    switch (factor) {
      case 'COMPETENCIAS':        return Icons.psychology_rounded;
      case 'ESFUERZO':            return Icons.fitness_center_rounded;
      case 'RESPONSABILIDAD':     return Icons.assignment_turned_in_rounded;
      case 'CONDICIONES DE TRABAJO': return Icons.health_and_safety_rounded;
      default:                    return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitulo(),
                  const SizedBox(height: 14),
                  _buildTotales(),
                  const SizedBox(height: 18),
                  _buildResumenFactores(),
                  const SizedBox(height: 18),
                  _buildTabla(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A1060), Color(0xFF6B2D8B), Color(0xFF9C4DBC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                nombres.isNotEmpty ? nombres[0].toUpperCase() : 'U',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${nombres.split(' ').first}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Calibración de Factores',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Círculos decorativos
          Stack(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              top: 8, left: 8,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildTitulo() {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6B2D8B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Tabla de Calibración',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3A1060)),
        ),
      ],
    );
  }

  Widget _buildTotales() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A1060), Color(0xFF6B2D8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B2D8B).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.percent_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  '100.0%',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Peso Total Asignado',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A9E1A), Color(0xFF7DC242)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7DC242).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  '1000 Pts',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Puntos Totales Máximos',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenFactores() {
    return Row(
      children: _factores.map((f) {
        final color = _colorFactor(f['factor']);
        final icon = _iconFactor(f['factor']);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: f == _factores.last ? 0 : 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  f['porcentaje'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
                Text(
                  _shortName(f['factor']),
                  style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortName(String factor) {
    switch (factor) {
      case 'COMPETENCIAS':        return 'Competencias';
      case 'ESFUERZO':            return 'Esfuerzo';
      case 'RESPONSABILIDAD':     return 'Responsab.';
      case 'CONDICIONES DE TRABAJO': return 'Condiciones';
      default:                    return factor;
    }
  }

  Widget _buildTabla() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2D8B).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Encabezado tabla
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: const Color(0xFF6B2D8B).withOpacity(0.08),
              child: const Row(
                children: [
                  Expanded(flex: 5, child: Text('Sub-Factor',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF6B2D8B)))),
                  SizedBox(width: 4),
                  SizedBox(width: 28, child: Text('%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF6B2D8B)))),
                  SizedBox(width: 4),
                  SizedBox(width: 24, child: Text('Pts',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF6B2D8B)))),
                  SizedBox(width: 4),
                  Expanded(flex: 4, child: Text('1    2    3    4    5',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF6B2D8B)))),
                  SizedBox(width: 4),
                  SizedBox(width: 24, child: Text('Var.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF6B2D8B)))),
                ],
              ),
            ),

            // Filas por factor
            for (int fi = 0; fi < _factores.length; fi++) ...[
              _buildFactorHeader(_factores[fi]),
              for (int si = 0; si < (_factores[fi]['subfactores'] as List).length; si++)
                _buildSubfactorRow(
                  _factores[fi]['subfactores'][si],
                  _colorFactor(_factores[fi]['factor']),
                  si % 2 == 0,
                ),
            ],

            // Fila TOTAL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A1060), Color(0xFF6B2D8B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 5, child: Text('TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                  const SizedBox(width: 4),
                  SizedBox(width: 28, child: const Text('100%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                  const SizedBox(width: 4),
                  SizedBox(width: 24, child: const Text('1000',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white))),
                  const SizedBox(width: 4),
                  const Expanded(flex: 4, child: SizedBox()),
                  const SizedBox(width: 4),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorHeader(Map<String, dynamic> factor) {
    final color = _colorFactor(factor['factor']);
    final icon = _iconFactor(factor['factor']);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: color.withOpacity(0.07),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '${factor['factor']}  ·  ${factor['porcentaje']}',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSubfactorRow(Map<String, dynamic> sf, Color accentColor, bool isEven) {
    final grados = (sf['grados'] as List).map((g) => '$g').toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: isEven ? Colors.white : const Color(0xFFFAF8FC),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre sub-factor — flexible, toma el espacio restante
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3, height: 28,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: Text(
                    sf['nombre'],
                    style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // % — ancho fijo
          SizedBox(
            width: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                sf['pct'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.bold, color: accentColor),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Pts — ancho fijo
          SizedBox(
            width: 24,
            child: Text(
              '${sf['pts']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF555555)),
            ),
          ),
          const SizedBox(width: 4),
          // Grados — 5 valores como texto separado por espacio, en Expanded
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: grados.map((g) => Text(
                g,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: accentColor.withOpacity(0.85)),
              )).toList(),
            ),
          ),
          const SizedBox(width: 4),
          // Var — ancho fijo
          SizedBox(
            width: 24,
            child: Text(
              '${sf['var']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}