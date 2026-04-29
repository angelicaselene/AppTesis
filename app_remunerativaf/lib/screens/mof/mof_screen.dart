import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MofScreen extends StatefulWidget {
  final String nombres;
  const MofScreen({super.key, required this.nombres});

  @override
  State<MofScreen> createState() => _MofScreenState();
}

class _MofScreenState extends State<MofScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _puestos = [];
  List<dynamic> _categorias = [];
  String? _categoriaSeleccionada;
  String? _nivelSeleccionado;
  final _buscarController = TextEditingController();
  bool _loading = true;
  bool _filtrosVisibles = false;

  late AnimationController _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _cargarCategorias();
    _cargarPuestos();
  }

  @override
  void dispose() {
    _animController.dispose();
    _buscarController.dispose();
    super.dispose();
  }

  String _toOracion(String texto) {
    if (texto.isEmpty) return texto;
    final lower = texto.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Future<void> _cargarCategorias() async {
    final data = await ApiService.getCategorias();
    setState(() => _categorias = data);
  }

  Future<void> _cargarPuestos() async {
    setState(() => _loading = true);
    final data = await ApiService.getMof(
      categoria: _categoriaSeleccionada,
      nivel: _nivelSeleccionado,
      buscar: _buscarController.text.isEmpty ? null : _buscarController.text,
    );
    setState(() {
      _puestos = data;
      _loading = false;
    });
    _animController.forward(from: 0);
  }

  Color _colorCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS':
        return const Color(0xFF7DC242);
      case 'ACADÉMICOS':
        return const Color(0xFF6B2D8B);
      case 'TÁCTICOS':
        return const Color(0xFF2196F3);
      case 'OPERATIVOS':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  IconData _iconCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'ESTRATÉGICOS':
        return Icons.star_rounded;
      case 'ACADÉMICOS':
        return Icons.school_rounded;
      case 'TÁCTICOS':
        return Icons.military_tech_rounded;
      case 'OPERATIVOS':
        return Icons.engineering_rounded;
      default:
        return Icons.circle;
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _categoriaSeleccionada = null;
      _nivelSeleccionado = null;
      _buscarController.clear();
    });
    _cargarPuestos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiltrosToggle(),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _filtrosVisibles
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildFiltros(),
                    secondChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  _buildContadorResultados(),
                  const SizedBox(height: 8),
                  _buildHeaderTabla(),
                  const SizedBox(height: 4),
                  _loading
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6B2D8B),
                            ),
                          ),
                        )
                      : _puestos.isEmpty
                          ? _buildEmptyState()
                          : Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: _puestos.length,
                                  itemBuilder: (context, index) =>
                                      _buildPuestoCard(_puestos[index]),
                                ),
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

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3A1060),
            Color(0xFF6B2D8B),
            Color(0xFF9C4DBC),
          ],
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
                widget.nombres.isNotEmpty
                    ? widget.nombres[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.nombres.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Clasificación de Puestos (MOF)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Círculos decorativos
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosToggle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6B2D8B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Puestos MOF',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3A1060),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _filtrosVisibles = !_filtrosVisibles),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded,
                  size: 16,
                  color: _filtrosVisibles ? Colors.white : const Color(0xFF6B2D8B),
                ),
                const SizedBox(width: 4),
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 13,
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'Categoría',
                  icon: Icons.category_rounded,
                  value: _categoriaSeleccionada,
                  items: _categorias
                      .map((c) => DropdownMenuItem(
                            value: c.toString(),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _colorCategoria(c.toString()),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    c.toString(),
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _categoriaSeleccionada = val);
                    _cargarPuestos();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  hint: 'Nivel',
                  icon: Icons.bar_chart_rounded,
                  value: _nivelSeleccionado,
                  items: ['I', 'II', 'III', 'IV', 'V', 'VI']
                      .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('Nivel $n',
                                style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _nivelSeleccionado = val);
                    _cargarPuestos();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscarController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar puesto...',
                    hintStyle: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF6B2D8B)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    filled: true,
                    fillColor: const Color(0xFFF4F0F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF6B2D8B), width: 1.5),
                    ),
                  ),
                  onChanged: (_) => _cargarPuestos(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _limpiarFiltros,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Icon(Icons.clear_rounded,
                      size: 18, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? const Color(0xFF6B2D8B)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Color(0xFF6B2D8B)),
          hint: Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(hint,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF3A1060)),
        ),
      ),
    );
  }

  Widget _buildContadorResultados() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6B2D8B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_puestos.length} resultado${_puestos.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B2D8B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTabla() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B2D8B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Categoría',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF6B2D8B))),
          ),
          Expanded(
            flex: 2,
            child: Text('Perfil',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF6B2D8B))),
          ),
          Expanded(
            flex: 1,
            child: Text('Niv.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF6B2D8B))),
          ),
          Expanded(
            flex: 4,
            child: Text('Puesto',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF6B2D8B))),
          ),
        ],
      ),
    );
  }

  Widget _buildPuestoCard(dynamic p) {
    final color = _colorCategoria(p['categoria'] ?? '');
    final icon = _iconCategoria(p['categoria'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Acento lateral de color
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    // Categoría con ícono
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, size: 14, color: color),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              p['categoria'] ?? '',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Perfil
                    Expanded(
                      flex: 2,
                      child: Text(
                        _toOracion(p['perfil'] ?? ''),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF555555)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    // Nivel
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B2D8B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p['nivel'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B2D8B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Puesto
                    Expanded(
                      flex: 4,
                      child: Text(
                        _toOracion(p['puesto'] ?? ''),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A2A2A),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6B2D8B).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_off_rounded,
                size: 48,
                color: Color(0xFF6B2D8B),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron puestos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF3A1060),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Intenta cambiar los filtros de búsqueda',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}