import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ValoracionPuestosScreen extends StatefulWidget {
  final String nombres;
  const ValoracionPuestosScreen({super.key, required this.nombres});

  @override
  State<ValoracionPuestosScreen> createState() => _ValoracionPuestosScreenState();
}

class _ValoracionPuestosScreenState extends State<ValoracionPuestosScreen> {
  Map<String, dynamic>? _perfil;
  Map<String, dynamic>? _valuacion;
  bool _loading = true;

  static const List<Map<String, dynamic>> _subfactores = [
    {'key': 'formacion_profesional', 'label': 'FORMACIÓN PROFESIONAL', 'max': 100},
    {'key': 'investigacion', 'label': 'INVESTIGACIÓN', 'max': 50},
    {'key': 'experiencia', 'label': 'EXPERIENCIA', 'max': 100},
    {'key': 'excelencia_servicio', 'label': 'EXCELENCIA DE SERVICIO', 'max': 50},
    {'key': 'capacidad_resolutiva', 'label': 'CAPACIDAD RESOLUTIVA', 'max': 50},
    {'key': 'emprendimiento', 'label': 'EMPRENDIMIENTO', 'max': 50},
    {'key': 'innovacion', 'label': 'INNOVACIÓN', 'max': 50},
    {'key': 'competencia_digital', 'label': 'COMPETENCIA DIGITAL', 'max': 50},
    {'key': 'mental', 'label': 'ESFUERZO MENTAL', 'max': 50},
    {'key': 'emocional', 'label': 'ESFUERZO EMOCIONAL', 'max': 50},
    {'key': 'fisico', 'label': 'ESFUERZO FÍSICO', 'max': 50},
    {'key': 'cumplimiento_metas', 'label': 'CUMPLIMIENTO DE METAS', 'max': 50},
    {'key': 'responsabilidades_financieras', 'label': 'RESPONSABILIDADES FINANCIERAS', 'max': 60},
    {'key': 'prestacion_servicios', 'label': 'PRESTACIÓN DE SERVICIOS', 'max': 50},
    {'key': 'confidencialidad', 'label': 'CONFIDENCIALIDAD', 'max': 50},
    {'key': 'manejo_materiales', 'label': 'MANEJO DE MATERIALES', 'max': 40},
    {'key': 'manejo_personas', 'label': 'MANEJO DE PERSONAS', 'max': 50},
    {'key': 'riesgo_ambiental', 'label': 'RIESGO AMBIENTAL', 'max': 20},
    {'key': 'riesgo_psicologico', 'label': 'RIESGO PSICOLÓGICO', 'max': 30},
  ];

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
    return _subfactores.fold(
      0,
      (sum, sf) => sum + ((_valuacion![sf['key']] ?? 0) as num).toInt(),
    );
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

                        // Card desglose
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF7DC242),
                              width: 2,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Desglose de la Valoración de tu Puesto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tu puesto tiene una valoración total de $puntos Puntos. Este puntaje determina tu ubicación en la banda $banda.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (_valuacion == null)
                                const Text(
                                  'Sin datos de valoración para este puesto.',
                                  style: TextStyle(color: Colors.black54),
                                )
                              else
                                for (final sf in _subfactores) ...[
                                  _barraSubfactor(
                                    sf['label'],
                                    (_valuacion![sf['key']] ?? 0) as num,
                                    sf['max'] as int,
                                  ),
                                  const SizedBox(height: 12),
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

  Widget _barraSubfactor(String label, num valor, int max) {
    final porcentaje = max > 0 ? valor / max : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '${valor.toInt()} de $max Puntos',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: porcentaje.toDouble(),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7DC242)),
          ),
        ),
      ],
    );
  }
}