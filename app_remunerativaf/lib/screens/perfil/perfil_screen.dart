import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  final String nombres;
  const PerfilScreen({super.key, required this.nombres});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _perfil;
  bool _loading = true;
  bool _editando = false;
  bool _guardando = false;
  bool _subiendoFoto = false;
  File? _fotoLocal;

  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await ApiService.getPerfil();
    setState(() {
      _perfil = data;
      _emailController.text = data['email'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';
      _loading = false;
    });
  }

  String _fixUrl(String? url) {
    if (url == null) return '';
    return url.replaceAll('127.0.0.1', '10.0.2.2');
  }

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6B2D8B)),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6B2D8B)),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _tomarFoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _subiendoFoto = true);

    final result = await ApiService.updateFoto(picked.path);

    setState(() {
      _subiendoFoto = false;
      if (result['foto_url'] != null) {
        _fotoLocal = File(picked.path);
        _perfil?['foto_url'] = result['foto_url'];
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Foto actualizada')),
      );
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final result = await ApiService.updatePerfil(
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );
    setState(() {
      _guardando = false;
      _editando = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Actualizado')),
      );
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
          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Avatar con botón de editar foto
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _subiendoFoto
                                ? const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Color(0xFFE0E0E0),
                                    child: CircularProgressIndicator(),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundColor: const Color(0xFFE0E0E0),
                                    backgroundImage: _fotoLocal != null
                                        ? FileImage(_fotoLocal!) as ImageProvider
                                        : _perfil?['foto_url'] != null
                                            ? NetworkImage(_fixUrl(_perfil!['foto_url']))
                                            : null,
                                    child: _fotoLocal == null &&
                                            _perfil?['foto_url'] == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                            GestureDetector(
                              onTap: _seleccionarFoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7DC242),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _perfil?['nombres'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _perfil?['rol'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Clasificación
                        if (_perfil?['clasificacion'] != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7DC242),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(children: [
                                  const Text('Categoría:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                  Text(
                                      _perfil!['clasificacion']['categoria'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ]),
                                Column(children: [
                                  const Text('Perfil:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                  Text(
                                      _perfil!['clasificacion']['perfil'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ]),
                                Column(children: [
                                  const Text('Nivel:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                  Text(
                                      _perfil!['clasificacion']['nivel'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ]),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Info personal
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _campoInfo('DNI', _perfil?['dni'] ?? ''),
                              const Divider(),
                              _campoEditable(
                                  'Teléfono', _telefonoController, _editando),
                              const Divider(),
                              _campoEditable('Correo electrónico',
                                  _emailController, _editando),
                              const Divider(),
                              _campoInfo(
                                  'Fecha de Nacimiento',
                                  _perfil?['fecha_nac'] ?? ''),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (!_editando)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _editando = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B2D8B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Editar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _editando = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancelar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _guardando ? null : _guardar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7DC242),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: _guardando
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text('Guardar',
                                          style:
                                              TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _campoInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Expanded(
              child: Text(valor, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _campoEditable(
      String label, TextEditingController controller, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: editable
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            )
          : Row(
              children: [
                Text('$label: ',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14)),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Sin datos' : controller.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
    );
  }
}