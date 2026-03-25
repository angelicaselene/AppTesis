import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MofScreen extends StatefulWidget {
  final String nombres;
  const MofScreen({super.key, required this.nombres});

  @override
  State<MofScreen> createState() => _MofScreenState();
}

class _MofScreenState extends State<MofScreen> {
  List<dynamic> _puestos = [];
  List<dynamic> _categorias = [];
  String? _categoriaSeleccionada;
  String? _nivelSeleccionado;
  final _buscarController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarPuestos();
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
                    'Clasificación de Puestos (MOF)',
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
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _categoriaSeleccionada = val);
                                  _cargarPuestos();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _nivelSeleccionado,
                                hint: const Text(
                                  'Nivel',
                                  style: TextStyle(fontSize: 13),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                items: ['I', 'II', 'III', 'IV', 'V', 'VI']
                                    .map(
                                      (n) => DropdownMenuItem(
                                        value: n,
                                        child: Text('Nivel $n'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _nivelSeleccionado = val);
                                  _cargarPuestos();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _buscarController,
                          decoration: InputDecoration(
                            hintText: 'Buscar Puesto',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (_) => _cargarPuestos(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Categoría',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Perfil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Nivel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Puesto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _puestos.length,
                            itemBuilder: (context, index) {
                              final p = _puestos[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        p['categoria'],
                                        style: TextStyle(
                                          color: _colorCategoria(
                                            p['categoria'],
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        p['perfil'] ?? '',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        p['nivel'] ?? '',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        p['puesto'] ?? '',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
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
