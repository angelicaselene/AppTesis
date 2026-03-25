import 'package:flutter/material.dart';

class CalibracionScreen extends StatelessWidget {
  final String nombres;
  const CalibracionScreen({super.key, required this.nombres});

  static const List<Map<String, dynamic>> _factores = [
    {
      'factor': 'COMPETENCIAS',
      'porcentaje': '50%',
      'subfactores': [
        {
          'nombre': 'Formación Profesional',
          'pct': '10%',
          'pts': 100,
          'grados': [20, 40, 60, 80, 100],
          'var': 20,
        },
        {
          'nombre': 'Investigación',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Experiencia',
          'pct': '10%',
          'pts': 100,
          'grados': [20, 40, 60, 80, 100],
          'var': 20,
        },
        {
          'nombre': 'Excelencia de servicio y atención al cliente',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Capacidad resolutiva',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Emprendimiento',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Innovación',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Competencia Digital',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
      ],
    },
    {
      'factor': 'ESFUERZO',
      'porcentaje': '15%',
      'subfactores': [
        {
          'nombre': 'Mental',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Emocional',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Físico',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
      ],
    },
    {
      'factor': 'RESPONSABILIDAD',
      'porcentaje': '30%',
      'subfactores': [
        {
          'nombre': 'Cumplimiento de metas',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Responsabilidades financieras',
          'pct': '6%',
          'pts': 60,
          'grados': [12, 24, 36, 48, 60],
          'var': 12,
        },
        {
          'nombre': 'Prestación de servicios',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Confidencialidad',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
        {
          'nombre': 'Manejo de materiales, financieros y tecnológicos',
          'pct': '4%',
          'pts': 40,
          'grados': [8, 16, 24, 32, 40],
          'var': 8,
        },
        {
          'nombre': 'Manejo de personas',
          'pct': '5%',
          'pts': 50,
          'grados': [10, 20, 30, 40, 50],
          'var': 10,
        },
      ],
    },
    {
      'factor': 'CONDICIONES DE TRABAJO',
      'porcentaje': '5%',
      'subfactores': [
        {
          'nombre': 'Físico - Riesgos ambientales',
          'pct': '2%',
          'pts': 20,
          'grados': [4, 8, 12, 16, 20],
          'var': 4,
        },
        {
          'nombre': 'Riesgo psicológicos',
          'pct': '3%',
          'pts': 30,
          'grados': [6, 12, 18, 24, 30],
          'var': 6,
        },
      ],
    },
  ];

  Color _colorFactor(String factor) {
    switch (factor) {
      case 'COMPETENCIAS':
        return const Color(0xFF6B2D8B);
      case 'ESFUERZO':
        return const Color(0xFF2196F3);
      case 'RESPONSABILIDAD':
        return const Color(0xFF7DC242);
      case 'CONDICIONES DE TRABAJO':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
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
              top: 50,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Hola ${nombres.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calibración de Factores',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Totales
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6B2D8B),
                              width: 2,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '100.0%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B2D8B),
                                ),
                              ),
                              Text(
                                'Peso Total Asignado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
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
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7DC242),
                              width: 2,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '1000 Pts',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7DC242),
                                ),
                              ),
                              Text(
                                'Puntos Totales Máximos',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tabla
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Encabezado
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Sub-Factor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Ptos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '1  2  3  4  5',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Var.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Filas por factor
                        for (final factor in _factores) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${factor['factor']} (${factor['porcentaje']})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _colorFactor(factor['factor']),
                                ),
                              ),
                            ),
                          ),
                          for (final sf in factor['subfactores'] as List)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      sf['nombre'],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      sf['pct'],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${sf['pts']}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      (sf['grados'] as List).join('  '),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${sf['var']}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 1),
                        ],

                        // Total
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '100%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '1000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text('', style: TextStyle(fontSize: 12)),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
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
}
