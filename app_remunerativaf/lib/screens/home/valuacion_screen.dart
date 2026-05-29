import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ValuacionScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String nombres;
  const ValuacionScreen({
    super.key,
    required this.usuario,
    required this.nombres,
  });

  @override
  State<ValuacionScreen> createState() => _ValuacionScreenState();
}

class _ValuacionScreenState extends State<ValuacionScreen> {
  Map<String, dynamic>? _valuacion;
  bool _loading = true;

  static const List<Map<String, dynamic>> _subfactores = [
    {
      'key': 'formacion_profesional',
      'label': 'Formación Profesional',
      'factor': 'COMPETENCIAS',
    },
    {
      'key': 'investigacion',
      'label': 'Investigación',
      'factor': 'COMPETENCIAS',
    },
    {'key': 'experiencia', 'label': 'Experiencia', 'factor': 'COMPETENCIAS'},
    {
      'key': 'excelencia_servicio',
      'label': 'Excelencia de servicio y atención al cliente',
      'factor': 'COMPETENCIAS',
    },
    {
      'key': 'capacidad_resolutiva',
      'label': 'Capacidad resolutiva',
      'factor': 'COMPETENCIAS',
    },
    {
      'key': 'emprendimiento',
      'label': 'Emprendimiento',
      'factor': 'COMPETENCIAS',
    },
    {'key': 'innovacion', 'label': 'Innovación', 'factor': 'COMPETENCIAS'},
    {
      'key': 'competencia_digital',
      'label': 'Competencia Digital',
      'factor': 'COMPETENCIAS',
    },
    {'key': 'mental', 'label': 'Mental', 'factor': 'ESFUERZO'},
    {'key': 'emocional', 'label': 'Emocional', 'factor': 'ESFUERZO'},
    {'key': 'fisico', 'label': 'Físico', 'factor': 'ESFUERZO'},
    {
      'key': 'cumplimiento_metas',
      'label': 'Cumplimiento de metas',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'responsabilidades_financieras',
      'label': 'Responsabilidades financieras',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'prestacion_servicios',
      'label': 'Prestación de servicios',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'confidencialidad',
      'label': 'Confidencialidad',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'manejo_materiales',
      'label': 'Manejo de materiales, financieros y tecnológicos',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'manejo_personas',
      'label': 'Manejo de personas',
      'factor': 'RESPONSABILIDAD',
    },
    {
      'key': 'riesgo_ambiental',
      'label': 'Físico - Riesgos ambientales',
      'factor': 'CONDICIONES DE TRABAJO',
    },
    {
      'key': 'riesgo_psicologico',
      'label': 'Riesgo psicológicos',
      'factor': 'CONDICIONES DE TRABAJO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarValuacion();
  }

  Future<void> _cargarValuacion() async {
    final data = await ApiService.getValuacion(widget.usuario['id']);
    setState(() {
      _valuacion = data;
      _loading = false;
    });
  }

  int get _total {
    if (_valuacion == null) return 0;
    return _subfactores.fold(
      0,
      (sum, sf) => sum + ((_valuacion![sf['key']] ?? 0) as int),
    );
  }

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
                  'Hola ${widget.nombres.split(' ').first}',
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
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _valuacion == null
              ? const Expanded(
                  child: Center(child: Text('Sin valuación para este puesto')),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Valuación de Factores',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            
                          ],
                        ),
                        const SizedBox(height: 12),

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
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'Sub-Factor',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Puntaje',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),

                              // Filas agrupadas por factor
                              Builder(
                                builder: (_) {
                                  String? factorAnterior;
                                  List<Widget> filas = [];
                                  for (final sf in _subfactores) {
                                    if (sf['factor'] != factorAnterior) {
                                      factorAnterior = sf['factor'];
                                      filas.add(
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            8,
                                            12,
                                            4,
                                          ),
                                          child: Text(
                                            sf['factor'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: _colorFactor(sf['factor']),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final valor = _valuacion![sf['key']] ?? 0;
                                    filas.add(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                sf['label'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '$valor',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    filas.add(
                                      const Divider(
                                        height: 1,
                                        indent: 12,
                                        endIndent: 12,
                                      ),
                                    );
                                  }
                                  return Column(children: filas);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Puntuación total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6B2D8B),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Puntuación Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF6B2D8B),
                                ),
                              ),
                              Text(
                                '$_total/ 1000',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF6B2D8B),
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
