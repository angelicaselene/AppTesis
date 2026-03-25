import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BeneficiosScreen extends StatefulWidget {
  final String nombres;
  final bool mostrarBotonAgregar;
  const BeneficiosScreen({
    super.key,
    required this.nombres,
    this.mostrarBotonAgregar = true,
  });

  @override
  State<BeneficiosScreen> createState() => _BeneficiosScreenState();
}

class _BeneficiosScreenState extends State<BeneficiosScreen> {
  Map<String, dynamic>? _perfil;
  bool _loading = true;
  int? _beneficioSeleccionado;

  static const List<Map<String, dynamic>> _beneficios = [
    {
      'titulo': 'Tiempo de Servicio',
      'icono': Icons.access_time,
      'descripcion': 'Incentivos por Lealtad y experiencia',
      'nota': 'Su otorgamiento es por única vez y no es retroactivo.',
      'columnas': ['Antigüedad', 'Bono'],
      'filas': [
        ['05 años', 'S/ 1 000.00'],
        ['10 años', 'S/ 2 500.00'],
        ['15 años', 'S/ 5 000.00'],
        ['20 años', 'S/ 5 000.00'],
        ['25 años', 'S/ 5 000.00'],
        ['30 años', 'S/ 5 000.00'],
      ],
    },
    {
      'titulo': 'Manejo de Idiomas',
      'icono': Icons.language,
      'descripcion': 'Bono por Manejo de Idiomas',
      'nota': 'Su otorgamiento estará condicionado a evaluación al máximo nivel.',
      'columnas': ['Perfil', 'Bono'],
      'filas': [
        ['01 idioma', 'S/ 250.00'],
        ['02 idiomas', 'S/ 500.00'],
        ['03 idiomas', 'S/ 750.00'],
      ],
    },
    {
      'titulo': 'Cumplimiento de Metas',
      'icono': Icons.emoji_events,
      'descripcion': 'Cumplimiento de Metas',
      'nota': null,
      'columnas': ['Áreas', 'Bono'],
      'filas': [
        ['01 puesto', 'S/ 3 000.00'],
        ['02 puesto', 'S/ 2 000.00'],
        ['03 puesto', 'S/ 1 000.00'],
      ],
    },
    {
      'titulo': 'Excelencia Academica e Investigación',
      'icono': Icons.search,
      'descripcion': 'Incentivo por Docente – RENACYT',
      'nota': 'Este incentivo no es aplicable para los Docentes Investigadores.',
      'columnas': ['Nivel', 'Bono', 'I. Salarial', 'I. Salarial DTP'],
      'filas': [
        ['Nivel VII', 'S/ 500.00', '', ''],
        ['Nivel VI', '', 'S/ 200.00', 'S/ 2.00'],
        ['Nivel V', '', 'S/ 400.00', 'S/ 4.00'],
        ['Nivel IV', '', 'S/ 600.00', 'S/ 6.00'],
        ['Nivel III', '', 'S/ 800.00', 'S/ 8.00'],
        ['Nivel II', '', 'S/ 1000.00', 'S/ 10.00'],
        ['Nivel I', '', 'S/ 1500.00', 'S/ 15.00'],
        ['Nivel 0 - Inv. Distinguido', '', 'S/ 2000.00', 'S/ 20.00'],
      ],
    },
    {
      'titulo': 'Bono por Ordinarización',
      'icono': Icons.trending_up,
      'descripcion': 'Bono por Ordinarización',
      'nota': null,
      'columnas': ['Nivel', 'Categoría', 'Bono'],
      'filas': [
        ['Docentes Auxiliares', 'Docente T. Completo.\nDocente T. Parcial.', 'S/ 500.00'],
        ['Docentes Asociados', 'Docente T. Completo.\nDocente T. Parcial.', 'S/ 1 000.00'],
        ['Docentes Principales', 'Docente T. Completo.\nDocente T. Parcial.', 'S/ 2 000.00'],
      ],
    },
    {
      'titulo': 'Obtención de Grado Doctor',
      'icono': Icons.school,
      'descripcion': 'Bono por obtención de grado de doctor',
      'nota': 'Su otorgamiento no es retroactivo.',
      'columnas': ['Colaborador', 'Incentivo'],
      'filas': [
        ['Docentes tiempo completo', 'S/ 500.00'],
        ['Administrativos tiempo completo', 'S/ 500.00'],
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await ApiService.getPerfil();
    setState(() {
      _perfil = data;
      _loading = false;
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                const Icon(Icons.person_outline, color: Colors.white, size: 28),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Card puesto actual
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4,
                                ),
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
                              const SizedBox(height: 6),
                              Text(
                                _perfil?['contrato']?['cargo'] ?? 'Sin cargo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Categoría: ${_perfil?['clasificacion']?['categoria'] ?? 'N/A'} - ${_perfil?['clasificacion']?['perfil'] ?? ''} ${_perfil?['clasificacion']?['nivel'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_beneficioSeleccionado == null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Reconocemos tu\nlealtad y compromiso',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    // Solo mostrar si es RR.HH
                                    if (widget.mostrarBotonAgregar)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7DC242),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                for (int i = 0; i < _beneficios.length; i++)
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _beneficioSeleccionado = i,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _beneficios[i]['icono'] as IconData,
                                            color: const Color(0xFF7DC242),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _beneficios[i]['titulo'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MIS BENEFICIOS USS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF6B2D8B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _beneficios[_beneficioSeleccionado!]['icono'] as IconData,
                                        color: const Color(0xFF7DC242),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _beneficios[_beneficioSeleccionado!]['titulo'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _beneficios[_beneficioSeleccionado!]['descripcion'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Table(
                                  border: TableBorder.all(color: Colors.grey.shade200),
                                  columnWidths: const {0: FlexColumnWidth(2)},
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(color: Colors.grey.shade100),
                                      children: [
                                        for (final col in _beneficios[_beneficioSeleccionado!]['columnas'] as List)
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              col,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    for (final fila in _beneficios[_beneficioSeleccionado!]['filas'] as List)
                                      TableRow(
                                        children: [
                                          for (final celda in fila as List)
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(celda, style: const TextStyle(fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                if (_beneficios[_beneficioSeleccionado!]['nota'] != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nota: ${_beneficios[_beneficioSeleccionado!]['nota']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () => setState(() => _beneficioSeleccionado = null),
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF6B2D8B)),
                                  label: const Text('Volver', style: TextStyle(color: Color(0xFF6B2D8B))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}