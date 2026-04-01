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

  Color _colorPunto(int index) {
    if (index == _historial.length - 1) return const Color(0xFF7DC242);
    if (index == 0) return const Color(0xFF6B2D8B);
    return const Color(0xFF9B4DBB);
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header morado
          Container(
            color: const Color(0xFF6B2D8B),
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
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
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Categoría: ${clasificacion?['categoria'] ?? 'N/A'} - ${clasificacion?['perfil'] ?? ''} ${clasificacion?['nivel'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card historial
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF7DC242), width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mi Historial Salarial y Puestos',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const SizedBox(height: 3),
                              if (_historial.isEmpty)
                                const Center(
                                  child: Text(
                                    'Sin historial disponible',
                                    style: TextStyle(color: Colors.black54),
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

                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: _colorPunto(index),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                if (!isLast)
                                                  Expanded(
                                                    child: Container(
                                                      width: 2,
                                                      color: Colors.grey.shade300,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${item['mes']?.toString().toLowerCase() ?? ''}. ${item['anio'] ?? ''}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item['cargo'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'S/ ${item['remuneracion'] ?? '0.00'}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
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
}