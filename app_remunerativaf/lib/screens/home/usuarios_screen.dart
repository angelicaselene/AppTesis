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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión Usuario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF7DC242),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _categoriaSeleccionada,
                                hint: const Text(
                                  'Categoría',
                                  style: TextStyle(fontSize: 13),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                items: _categorias
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.toString(),
                                        child: Text(
                                          c.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _categoriaSeleccionada = val);
                                  _cargarUsuarios();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _puestoController,
                                decoration: InputDecoration(
                                  hintText: 'Puesto',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (_) => _cargarUsuarios(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nombreController,
                                decoration: InputDecoration(
                                  hintText: 'Nombre',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (_) => _cargarUsuarios(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _cargarUsuarios,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B2D8B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Buscar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _loading
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _usuarios.length + (_loadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _usuarios.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final u = _usuarios[index];
                              final categoria =
                                  u['clasificacion']?['categoria'];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(
                                    left: BorderSide(
                                      color: _colorCategoria(categoria),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              u['nombres'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: _colorCategoria(
                                                  categoria,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (categoria != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _colorCategoria(
                                                  categoria,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Categoría: $categoria',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _colorCategoria(
                                                    categoria,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        u['email'] ?? 'Sin email',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Estado: Activo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF7DC242),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Puesto: ${u['clasificacion']?['puesto'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Nivel: ${u['clasificacion']?['nivel'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    UsuarioDetalleScreen(
                                                      usuario: u,
                                                      nombres: widget.nombres,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Mas información',
                                            style: TextStyle(
                                              color: Color(0xFF6B2D8B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
