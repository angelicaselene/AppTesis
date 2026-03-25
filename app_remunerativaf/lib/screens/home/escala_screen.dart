import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EscalaScreen extends StatefulWidget {
  final String nombres;
  const EscalaScreen({super.key, required this.nombres});

  @override
  State<EscalaScreen> createState() => _EscalaScreenState();
}

class _EscalaScreenState extends State<EscalaScreen> {
  List<dynamic> _anios = [];
  List<dynamic> _escala = [];
  String _anioSeleccionado = '2025';
  String _seccionSeleccionada = 'ACADÉMICOS';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarAnios();
  }

  Future<void> _cargarAnios() async {
    final data = await ApiService.getEscalaAnios();
    setState(() {
      _anios = data;
      _anioSeleccionado = data.isNotEmpty ? data[0].toString() : '2025';
    });
    _cargarEscala();
  }

  Future<void> _cargarEscala() async {
    setState(() => _loading = true);
    final data = await ApiService.getEscala(
      anio: _anioSeleccionado,
      seccion: _seccionSeleccionada,
    );
    setState(() {
      _escala = data;
      _loading = false;
    });
  }

  Map<String, Map<String, List<dynamic>>> _agrupar() {
    final Map<String, Map<String, List<dynamic>>> resultado = {};
    for (final item in _escala) {
      final seccion = item['seccion'] ?? 'SIN SECCIÓN';
      final categoria = item['categoria'] ?? 'SIN CATEGORÍA';
      resultado.putIfAbsent(seccion, () => {});
      resultado[seccion]!.putIfAbsent(categoria, () => []);
      resultado[seccion]![categoria]!.add(item);
    }
    return resultado;
  }

  Color _colorCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS': return const Color(0xFF6B2D8B);
      case 'ACADÉMICOS': return const Color(0xFF2196F3);
      case 'TÁCTICOS': return const Color(0xFF7DC242);
      case 'OPERATIVOS': return const Color(0xFFFF9800);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final agrupado = _agrupar();

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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de Escala Remunerativa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dropdown año
                        const Text(
                          'Año de la propuesta',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _anioSeleccionado,
                              isExpanded: true,
                              items: _anios.map((a) => DropdownMenuItem(
                                value: a.toString(),
                                child: Text(
                                  'Escala Salarial ${a.toString()}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _anioSeleccionado = val);
                                  _cargarEscala();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dropdown sección
                        const Text(
                          'Sección',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _seccionSeleccionada,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'ACADÉMICOS',
                                  child: Text('Académicos', style: TextStyle(fontSize: 14)),
                                ),
                                DropdownMenuItem(
                                  value: 'ADMINISTRATIVOS',
                                  child: Text('Administrativos', style: TextStyle(fontSize: 14)),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _seccionSeleccionada = val);
                                  _cargarEscala();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tablas por sección
                        for (final seccion in agrupado.keys) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B2D8B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ESCALA DE REMUNERACIONES $seccion - USS',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.grey.shade100,
                                ),
                                columnSpacing: 16,
                                headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                dataTextStyle: const TextStyle(fontSize: 12),
                                columns: const [
                                  DataColumn(label: Text('CATEGORÍA')),
                                  DataColumn(label: Text('PERFIL')),
                                  DataColumn(label: Text('NIVEL')),
                                  DataColumn(label: Text('PUESTO')),
                                  DataColumn(label: Text('MODALIDAD')),
                                  DataColumn(label: Text('VALOR')),
                                  DataColumn(label: Text('JUNIOR')),
                                  DataColumn(label: Text('SENIOR')),
                                  DataColumn(label: Text('MASTER')),
                                ],
                                rows: agrupado[seccion]!.entries.expand((entry) {
                                  final categoria = entry.key;
                                  return entry.value.map((item) => DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _colorCategoria(categoria).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            categoria,
                                            style: TextStyle(
                                              color: _colorCategoria(categoria),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item['perfil'] ?? '-')),
                                      DataCell(Text(item['nivel'] ?? '-')),
                                      DataCell(
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            item['puesto'] ?? '-',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item['modalidad'] ?? '-')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6B2D8B).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['valor']?.toString() ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6B2D8B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(_celdaValor(item['junior'])),
                                      DataCell(_celdaValor(item['senior'])),
                                      DataCell(_celdaValor(item['master'])),
                                    ],
                                  ));
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _celdaValor(dynamic valor) {
    if (valor == null) {
      return Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          '-',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.black38),
        ),
      );
    }
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF7DC242).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF7DC242).withOpacity(0.3)),
      ),
      child: Text(
        'S/${valor.toString()}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7DC242),
        ),
      ),
    );
  }
}