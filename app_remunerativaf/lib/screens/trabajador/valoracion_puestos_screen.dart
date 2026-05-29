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
    {'key': 'formacion_profesional', 'label': 'Formación Profesional', 'grupo': 'CONOCIMIENTOS', 'max': 100},
    {'key': 'investigacion', 'label': 'Investigación', 'grupo': 'CONOCIMIENTOS', 'max': 50},
    {'key': 'experiencia', 'label': 'Experiencia', 'grupo': 'CONOCIMIENTOS', 'max': 100},
    {'key': 'excelencia_servicio', 'label': 'Excelencia de Servicio', 'grupo': 'HABILIDADES', 'max': 50},
    {'key': 'capacidad_resolutiva', 'label': 'Capacidad Resolutiva', 'grupo': 'HABILIDADES', 'max': 50},
    {'key': 'emprendimiento', 'label': 'Emprendimiento', 'grupo': 'HABILIDADES', 'max': 50},
    {'key': 'innovacion', 'label': 'Innovación', 'grupo': 'HABILIDADES', 'max': 50},
    {'key': 'competencia_digital', 'label': 'Competencia Digital', 'grupo': 'HABILIDADES', 'max': 50},
    {'key': 'mental', 'label': 'Esfuerzo Mental', 'grupo': 'ESFUERZO', 'max': 50},
    {'key': 'emocional', 'label': 'Esfuerzo Emocional', 'grupo': 'ESFUERZO', 'max': 50},
    {'key': 'fisico', 'label': 'Esfuerzo Físico', 'grupo': 'ESFUERZO', 'max': 50},
    {'key': 'cumplimiento_metas', 'label': 'Cumplimiento de Metas', 'grupo': 'RESPONSABILIDADES', 'max': 50},
    {'key': 'responsabilidades_financieras', 'label': 'Responsabilidades Financieras', 'grupo': 'RESPONSABILIDADES', 'max': 60},
    {'key': 'prestacion_servicios', 'label': 'Prestación de Servicios', 'grupo': 'RESPONSABILIDADES', 'max': 50},
    {'key': 'confidencialidad', 'label': 'Confidencialidad', 'grupo': 'RESPONSABILIDADES', 'max': 50},
    {'key': 'manejo_materiales', 'label': 'Manejo de Materiales', 'grupo': 'RESPONSABILIDADES', 'max': 40},
    {'key': 'manejo_personas', 'label': 'Manejo de Personas', 'grupo': 'RESPONSABILIDADES', 'max': 50},
    {'key': 'riesgo_ambiental', 'label': 'Riesgo Ambiental', 'grupo': 'CONDICIONES', 'max': 20},
    {'key': 'riesgo_psicologico', 'label': 'Riesgo Psicológico', 'grupo': 'CONDICIONES', 'max': 30},
  ];

  static const Map<String, Map<String, dynamic>> _grupoInfo = {
    'CONOCIMIENTOS': {'icono': Icons.school_outlined, 'color': Color(0xFF6B2D8B)},
    'HABILIDADES':   {'icono': Icons.psychology_outlined, 'color': Color(0xFF7DC242)},
    'ESFUERZO':      {'icono': Icons.fitness_center_outlined, 'color': Color(0xFF9B4DBB)},
    'RESPONSABILIDADES': {'icono': Icons.assignment_outlined, 'color': Color(0xFF4A1570)},
    'CONDICIONES':   {'icono': Icons.warning_amber_outlined, 'color': Color(0xFFE67E22)},
  };

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
    return _subfactores.fold(0, (sum, sf) => sum + ((_valuacion![sf['key']] ?? 0) as num).toInt());
  }

  int _puntosGrupo(String grupo) {
    if (_valuacion == null) return 0;
    return _subfactores
        .where((sf) => sf['grupo'] == grupo)
        .fold(0, (sum, sf) => sum + ((_valuacion![sf['key']] ?? 0) as num).toInt());
  }

  int _maxGrupo(String grupo) {
    return _subfactores
        .where((sf) => sf['grupo'] == grupo)
        .fold(0, (sum, sf) => sum + (sf['max'] as int));
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

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];
    final puntos = _calcularPuntos();
    final banda = _calcularBanda(puntos);
    final colorBanda = _colorBanda(banda);
    final grupos = _grupoInfo.keys.toList();

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
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                        // Card resumen de puntos
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B2D8B), Color(0xFF9B4DBB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF6B2D8B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Valoración Total', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('$puntos pts', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Categoría: ${clasificacion?['categoria'] ?? 'N/A'} · ${clasificacion?['perfil'] ?? ''} ${clasificacion?['nivel'] ?? ''}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: colorBanda,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                                    const SizedBox(height: 4),
                                    Text(banda, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resumen por grupos
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Resumen por Factor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D1040))),
                              const SizedBox(height: 14),
                              ...grupos.map((grupo) {
                                final info = _grupoInfo[grupo]!;
                                final pts = _puntosGrupo(grupo);
                                final max = _maxGrupo(grupo);
                                final pct = max > 0 ? pts / max : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: (info['color'] as Color).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(info['icono'] as IconData, color: info['color'] as Color, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(grupo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2D1040))),
                                                Text('$pts / $max', style: TextStyle(fontSize: 11, color: info['color'] as Color, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: pct.toDouble(),
                                                minHeight: 6,
                                                backgroundColor: Colors.grey.shade100,
                                                valueColor: AlwaysStoppedAnimation<Color>(info['color'] as Color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Desglose detallado por grupo
                        if (_valuacion != null)
                          ...grupos.map((grupo) {
                            final info = _grupoInfo[grupo]!;
                            final color = info['color'] as Color;
                            final icono = info['icono'] as IconData;
                            final items = _subfactores.where((sf) => sf['grupo'] == grupo).toList();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icono, color: color, size: 18),
                                    ),
                                    title: Text(grupo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                                    subtitle: Text(
                                      '${_puntosGrupo(grupo)} de ${_maxGrupo(grupo)} puntos',
                                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                                    ),
                                    children: items.map((sf) {
                                      final valor = (_valuacion![sf['key']] ?? 0) as num;
                                      final max = sf['max'] as int;
                                      final pct = max > 0 ? valor / max : 0.0;
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(sf['label'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    '${valor.toInt()}/$max',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: pct.toDouble(),
                                                minHeight: 7,
                                                backgroundColor: Colors.grey.shade100,
                                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          }),

                        if (_valuacion == null)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text('Sin datos de valoración para este puesto.', style: TextStyle(color: Colors.black45)),
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