import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistorialScreen extends StatefulWidget {
  final String nombres;
  const HistorialScreen({super.key, required this.nombres});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> _historial = [];
  Map<String, dynamic>? _perfil;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final perfil = await ApiService.getPerfil();
    final historial = await ApiService.getHistorialRemuneracion();
    setState(() {
      _perfil = perfil;
      _historial = historial;
      _loading = false;
    });
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

  // Detecta si hubo cambio de salario respecto al anterior
  bool _subio(int index) {
    if (index == 0) return false;
    final actual = double.tryParse(_historial[index]['remuneracion']?.toString() ?? '0') ?? 0;
    final anterior = double.tryParse(_historial[index - 1]['remuneracion']?.toString() ?? '0') ?? 0;
    return actual > anterior;
  }

  bool _bajo(int index) {
    if (index == 0) return false;
    final actual = double.tryParse(_historial[index]['remuneracion']?.toString() ?? '0') ?? 0;
    final anterior = double.tryParse(_historial[index - 1]['remuneracion']?.toString() ?? '0') ?? 0;
    return actual < anterior;
  }

  // Calcula variación porcentual
  String _variacion(int index) {
    if (index == 0) return '';
    final actual = double.tryParse(_historial[index]['remuneracion']?.toString() ?? '0') ?? 0;
    final anterior = double.tryParse(_historial[index - 1]['remuneracion']?.toString() ?? '0') ?? 0;
    if (anterior == 0) return '';
    final pct = ((actual - anterior) / anterior * 100);
    final signo = pct >= 0 ? '+' : '';
    return '$signo${pct.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];

    // Calcular salario máximo y mínimo para contexto
    double maxSalario = 0;
    double minSalario = double.infinity;
    for (final item in _historial) {
      final rem = double.tryParse(item['remuneracion']?.toString() ?? '0') ?? 0;
      if (rem > maxSalario) maxSalario = rem;
      if (rem < minSalario) minSalario = rem;
    }
    if (_historial.isEmpty) minSalario = 0;

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
                            color: const Color(0xFF7DC242).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${clasificacion?['categoria'] ?? ''} · ${clasificacion?['nivel'] ?? ''}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                        // Cards resumen
                        if (_historial.isNotEmpty) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _resumenCard(
                                  'Salario Inicial',
                                  'S/ ${double.tryParse(_historial.first['remuneracion']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                  Icons.start_outlined,
                                  const Color(0xFF6B2D8B),
                                  const Color(0xFFF0EDF5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _resumenCard(
                                  'Salario Actual',
                                  'S/ ${double.tryParse(_historial.last['remuneracion']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                  Icons.payments_outlined,
                                  const Color(0xFF7DC242),
                                  const Color(0xFFEEF7E5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _resumenCard(
                                  'Registros',
                                  '${_historial.length} meses',
                                  Icons.history_outlined,
                                  const Color(0xFF4A1570),
                                  const Color(0xFFF0EDF5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Timeline
                        Container(
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EDF5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.timeline, color: Color(0xFF6B2D8B), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Mi Historial Salarial',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D1040)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (_historial.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text('Sin historial disponible', style: TextStyle(color: Colors.black45)),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _historial.length,
                                  itemBuilder: (context, index) {
                                    final item = _historial[index];
                                    final isLast = index == _historial.length - 1;
                                    final isFirst = index == 0;
                                    final subio = _subio(index);
                                    final bajo = _bajo(index);
                                    final variacion = _variacion(index);
                                    final rem = double.tryParse(item['remuneracion']?.toString() ?? '0') ?? 0;

                                    // Color del punto según posición
                                    Color colorPunto = const Color(0xFF9B4DBB);
                                    if (isFirst) colorPunto = const Color(0xFF6B2D8B);
                                    if (isLast) colorPunto = const Color(0xFF7DC242);

                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Línea de tiempo
                                          SizedBox(
                                            width: 28,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color: colorPunto,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [BoxShadow(color: colorPunto.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
                                                  ),
                                                ),
                                                if (!isLast)
                                                  Expanded(
                                                    child: Container(
                                                      width: 2,
                                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [colorPunto, const Color(0xFF9B4DBB)],
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          // Card del item
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isLast ? const Color(0xFFEEF7E5) : const Color(0xFFF8F6FC),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isLast ? const Color(0xFF7DC242).withOpacity(0.4) : Colors.transparent,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${_capitalize(item['mes']?.toString() ?? '')} ${item['anio'] ?? ''}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: isLast ? const Color(0xFF7DC242) : Colors.black45,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            item['cargo'] ?? '',
                                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D1040)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          'S/ ${rem.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                            color: isLast ? const Color(0xFF7DC242) : const Color(0xFF6B2D8B),
                                                          ),
                                                        ),
                                                        if (variacion.isNotEmpty) ...[
                                                          const SizedBox(height: 3),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: subio
                                                                  ? const Color(0xFF7DC242).withOpacity(0.12)
                                                                  : bajo
                                                                      ? Colors.red.withOpacity(0.1)
                                                                      : Colors.grey.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  subio ? Icons.arrow_upward : bajo ? Icons.arrow_downward : Icons.remove,
                                                                  size: 10,
                                                                  color: subio ? const Color(0xFF7DC242) : bajo ? Colors.red : Colors.grey,
                                                                ),
                                                                const SizedBox(width: 2),
                                                                Text(
                                                                  variacion,
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: subio ? const Color(0xFF7DC242) : bajo ? Colors.red : Colors.grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _resumenCard(String label, String valor, IconData icono, Color color, Color bg) {
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
            child: Icon(icono, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 2),
          Text(valor, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}