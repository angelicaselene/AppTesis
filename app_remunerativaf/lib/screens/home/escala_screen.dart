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
  bool _filtrosVisibles = false;

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
      case 'ACADÉMICOS':   return const Color(0xFF2196F3);
      case 'TÁCTICOS':     return const Color(0xFF7DC242);
      case 'OPERATIVOS':   return const Color(0xFFFF9800);
      default:             return Colors.grey;
    }
  }

  IconData _iconCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS': return Icons.star_rounded;
      case 'ACADÉMICOS':   return Icons.school_rounded;
      case 'TÁCTICOS':     return Icons.military_tech_rounded;
      case 'OPERATIVOS':   return Icons.engineering_rounded;
      default:             return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final agrupado = _agrupar();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B2D8B)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitulo(),
                        const SizedBox(height: 14),
                        _buildFiltrosToggle(),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _filtrosVisibles
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: _buildFiltros(),
                          secondChild: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        _buildSeccionTabs(),
                        const SizedBox(height: 16),
                        for (final seccion in agrupado.keys) ...[
                          _buildSeccionTabla(seccion, agrupado[seccion]!),
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
        left: 16, right: 16, bottom: 20,
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
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                widget.nombres.isNotEmpty ? widget.nombres[0].toUpperCase() : 'U',
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
                Text('Hola, ${widget.nombres.split(' ').first}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Escala Remunerativa',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Stack(children: [
            Container(width: 50, height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05))),
            Positioned(top: 8, left: 8,
                child: Container(width: 34, height: 34,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08)))),
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
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        const Text('Detalles de Escala Remunerativa',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3A1060))),
      ],
    );
  }

  Widget _buildFiltrosToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => setState(() => _filtrosVisibles = !_filtrosVisibles),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _filtrosVisibles
                  ? const Color(0xFF6B2D8B)
                  : const Color(0xFF6B2D8B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _filtrosVisibles
                      ? Icons.tune_rounded
                      : Icons.tune_rounded,
                  size: 16,
                  color: _filtrosVisibles ? Colors.white : const Color(0xFF6B2D8B),
                ),
                const SizedBox(width: 6),
                Text(
                  _filtrosVisibles ? 'Ocultar filtros' : 'Año: $_anioSeleccionado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _filtrosVisibles ? Colors.white : const Color(0xFF6B2D8B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2D8B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Año de la propuesta',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          _buildDropdownStyled(
            icon: Icons.calendar_today_rounded,
            value: _anioSeleccionado,
            items: _anios.map((a) => DropdownMenuItem(
              value: a.toString(),
              child: Text('Escala Salarial ${a.toString()}',
                  style: const TextStyle(fontSize: 13)),
            )).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _anioSeleccionado = val);
                _cargarEscala();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownStyled({
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B2D8B), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B2D8B)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: Color(0xFF6B2D8B)),
                items: items,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13, color: Color(0xFF3A1060)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTabs() {
    final secciones = ['ACADÉMICOS', 'ADMINISTRATIVOS'];
    return Row(
      children: secciones.map((s) {
        final isSelected = _seccionSeleccionada == s;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _seccionSeleccionada = s);
              _cargarEscala();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: s == secciones.first ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3A1060), Color(0xFF6B2D8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF6B2D8B).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s == 'ACADÉMICOS'
                        ? Icons.school_rounded
                        : Icons.business_center_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF6B2D8B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s == 'ACADÉMICOS' ? 'Académicos' : 'Administrativos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : const Color(0xFF6B2D8B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeccionTabla(
      String seccion, Map<String, List<dynamic>> categorias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de sección
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3A1060), Color(0xFF6B2D8B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B2D8B).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'ESCALA DE REMUNERACIONES $seccion - USS',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tabla con scroll horizontal
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B2D8B).withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFF6B2D8B).withOpacity(0.08),
                ),
                columnSpacing: 14,
                horizontalMargin: 14,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF6B2D8B),
                ),
                dataTextStyle: const TextStyle(fontSize: 11),
                columns: const [
                  DataColumn(label: Text('CATEGORÍA')),
                  DataColumn(label: Text('PERFIL')),
                  DataColumn(label: Text('NIV.')),
                  DataColumn(label: Text('PUESTO')),
                  DataColumn(label: Text('MODALIDAD')),
                  DataColumn(label: Text('VALOR')),
                  DataColumn(label: Text('JUNIOR')),
                  DataColumn(label: Text('SENIOR')),
                  DataColumn(label: Text('MASTER')),
                ],
                rows: categorias.entries.expand((entry) {
                  final categoria = entry.key;
                  final color = _colorCategoria(categoria);
                  final icon = _iconCategoria(categoria);
                  return entry.value.map((item) => DataRow(
                    cells: [
                      // Categoría
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 10, color: color),
                              const SizedBox(width: 4),
                              Text(categoria,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                      // Perfil
                      DataCell(Text(item['perfil'] ?? '-',
                          style: const TextStyle(color: Color(0xFF555555)))),
                      // Nivel
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B2D8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(item['nivel'] ?? '-',
                              style: const TextStyle(
                                  color: Color(0xFF6B2D8B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ),
                      // Puesto
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(item['puesto'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF333333))),
                        ),
                      ),
                      // Modalidad
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(item['modalidad'] ?? '-',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade700)),
                        ),
                      ),
                      // Valor
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A1060), Color(0xFF6B2D8B)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['valor']?.toString() ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 11),
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
        ),
      ],
    );
  }

  Widget _celdaValor(dynamic valor) {
    if (valor == null) {
      return Container(
        width: 58,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text('-',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black38)),
      );
    }
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF7DC242).withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF7DC242).withOpacity(0.3)),
      ),
      child: Text(
        'S/${valor.toString()}',
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A9E1A)),
      ),
    );
  }
}