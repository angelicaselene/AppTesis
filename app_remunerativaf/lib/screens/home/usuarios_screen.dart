import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'usuario_detalle_screen.dart';

class UsuariosScreen extends StatefulWidget {
  final String nombres;
  const UsuariosScreen({super.key, required this.nombres});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<dynamic> _usuarios = [];
  List<dynamic> _categorias = [];
  String? _categoriaSeleccionada;
  final _nombreController = TextEditingController();
  final _puestoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  bool _hasMore = true;
  bool _filtrosExpanded = false;

  // ── Brand palette ──────────────────────────────────────────────
  static const Color _purple = Color(0xFF6B2D8B);
  static const Color _purpleLight = Color(0xFF9C4DBB);
  static const Color _purpleDark = Color(0xFF4A1D62);
  static const Color _green = Color(0xFF7DC242);
  static const Color _bg = Color(0xFFF4F0F8);
  // ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarUsuarios();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nombreController.dispose();
    _puestoController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    final data = await ApiService.getCategorias();
    setState(() => _categorias = data);
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _loading = true;
      _page = 1;
      _hasMore = true;
      _usuarios = [];
    });
    final data = await ApiService.getUsuarios(
      nombre: _nombreController.text,
      categoria: _categoriaSeleccionada,
      puesto: _puestoController.text,
      page: 1,
    );
    setState(() {
      _usuarios = data['data'] ?? [];
      _hasMore = data['next_page_url'] != null;
      _loading = false;
    });
  }

  Future<void> _cargarMas() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    _page++;
    final data = await ApiService.getUsuarios(
      nombre: _nombreController.text,
      categoria: _categoriaSeleccionada,
      puesto: _puestoController.text,
      page: _page,
    );
    setState(() {
      _usuarios.addAll(data['data'] ?? []);
      _hasMore = data['next_page_url'] != null;
      _loadingMore = false;
    });
  }

  void _limpiarFiltros() {
    _nombreController.clear();
    _puestoController.clear();
    setState(() => _categoriaSeleccionada = null);
    _cargarUsuarios();
  }

  Color _colorCategoria(String? categoria) {
    switch ((categoria ?? '').toUpperCase()) {
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

  IconData _iconoCategoria(String? categoria) {
    switch ((categoria ?? '').toUpperCase()) {
      case 'ESTRATÉGICOS':
        return Icons.star_rounded;
      case 'ACADÉMICOS':
        return Icons.school_rounded;
      case 'TÁCTICOS':
        return Icons.military_tech_rounded;
      case 'OPERATIVOS':
        return Icons.engineering_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildFiltros(),
          _buildResultCount(),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    final firstName = widget.nombres.split(' ').first;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_purpleDark, _purple, _purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Hola, $firstName',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Botón filtros toggle
          GestureDetector(
            onTap: () => setState(() => _filtrosExpanded = !_filtrosExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                children: [
                  Icon(
                    _filtrosExpanded
                        ? Icons.filter_list_off
                        : Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _filtrosExpanded ? 'Ocultar' : 'Filtros',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filtros ───────────────────────────────────────────────────
  Widget _buildFiltros() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 280),
      crossFadeState: _filtrosExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            // Dropdown categoría
            _buildDropdown(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nombreController,
                    hint: 'Buscar por nombre',
                    icon: Icons.person_search_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _puestoController,
                    hint: 'Buscar por puesto',
                    icon: Icons.business_center_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _cargarUsuarios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('Buscar',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _limpiarFiltros,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.clear_all_rounded,
                        color: _purple, size: 18),
                    label: const Text('Limpiar',
                        style: TextStyle(color: _purple)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      secondChild: const SizedBox.shrink(),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          hint: const Row(
            children: [
              Icon(Icons.category_rounded, size: 16, color: Colors.black45),
              SizedBox(width: 8),
              Text('Todas las categorías',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          items: _categorias.map((c) {
            return DropdownMenuItem(
              value: c.toString(),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colorCategoria(c.toString()),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(c.toString(), style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _categoriaSeleccionada = val);
            _cargarUsuarios();
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
        prefixIcon: Icon(icon, size: 18, color: Colors.black38),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
      onChanged: (_) => _cargarUsuarios(),
    );
  }

  // ── Contador resultados ───────────────────────────────────────
  Widget _buildResultCount() {
    if (_loading) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_usuarios.length} usuario${_usuarios.length != 1 ? 's' : ''} encontrado${_usuarios.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista ─────────────────────────────────────────────────────
  Widget _buildLista() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _purple),
      );
    }

    if (_usuarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No se encontraron usuarios',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _usuarios.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _usuarios.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: _purple),
            ),
          );
        }
        return _buildUsuarioCard(_usuarios[index]);
      },
    );
  }

  // ── Card usuario ──────────────────────────────────────────────
  Widget _buildUsuarioCard(dynamic u) {
    final categoria = u['clasificacion']?['categoria'] as String?;
    final color = _colorCategoria(categoria);
    final icono = _iconoCategoria(categoria);
    final nombre = u['nombres'] ?? '';
    final email = u['email'] ?? 'Sin email';
    final puesto = u['clasificacion']?['puesto'] ?? '';
    final nivel = u['clasificacion']?['nivel'] ?? '';
    final inicial =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UsuarioDetalleScreen(
              usuario: u,
              nombres: widget.nombres,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  inicial,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (categoria != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icono, size: 10, color: color),
                                const SizedBox(width: 3),
                                Text(
                                  categoria,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (puesto.isNotEmpty)
                          _buildChip(Icons.work_outline_rounded,
                              puesto, _purple),
                        if (nivel.isNotEmpty)
                          _buildChip(Icons.layers_rounded, nivel, _green),
                        _buildChip(
                            Icons.check_circle_outline_rounded,
                            'Activo',
                            _green),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: color.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}