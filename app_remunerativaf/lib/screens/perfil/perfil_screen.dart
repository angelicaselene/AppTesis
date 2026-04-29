import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  final String nombres;
  const PerfilScreen({super.key, required this.nombres});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _perfil;
  bool _loading = true;
  bool _editando = false;
  bool _guardando = false;
  bool _subiendoFoto = false;
  File? _fotoLocal;

  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Color palette consistent with rest of app
  static const Color _primary = Color(0xFF3A1060);
  static const Color _mid = Color(0xFF6B2D8B);
  static const Color _light = Color(0xFF9C4DBC);
  static const Color _green = Color(0xFF7DC242);
  static const Color _bg = Color(0xFFF3F0F7);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _cargarPerfil();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final data = await ApiService.getPerfil();
    final prefs = await SharedPreferences.getInstance();
    final dni = data['dni'] ?? '';
    final fotoGuardada = prefs.getString('foto_perfil_$dni');

    setState(() {
      _perfil = data;
      if (fotoGuardada != null) {
        _perfil?['foto_local'] = fotoGuardada;
      }
      _emailController.text = data['email'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';
      _loading = false;
    });
    _animController.forward();
  }

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _mid.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: _mid),
                ),
                title: const Text('Tomar foto',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _tomarFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _mid.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: _mid),
                ),
                title: const Text('Elegir de galería',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _tomarFoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tomarFoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 400,
      imageQuality: 50,
    );
    if (picked == null) return;

    setState(() => _subiendoFoto = true);

    final bytes = await File(picked.path).readAsBytes();
    final base64Str = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    final dni = _perfil?['dni'] ?? '';
    await prefs.setString('foto_perfil_$dni', base64Str);

    await ApiService.updateFoto(picked.path);

    setState(() {
      _subiendoFoto = false;
      _fotoLocal = File(picked.path);
      _perfil?['foto_local'] = base64Str;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Foto actualizada correctamente'),
            ],
          ),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        SnackBar(
          content: Text(result['message'] ?? 'Actualizado'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildAvatar() {
    Widget avatarContent;

    if (_subiendoFoto) {
      avatarContent = Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else if (_fotoLocal != null) {
      avatarContent = ClipOval(
        child: Image.file(
          _fotoLocal!,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final fotoLocal = _perfil?['foto_local'];
      if (fotoLocal != null) {
        try {
          final bytes = base64Decode(fotoLocal);
          avatarContent = ClipOval(
            child: Image.memory(
              bytes,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          avatarContent = _defaultAvatar();
        }
      } else {
        avatarContent = _defaultAvatar();
      }
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFE0C8F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: avatarContent,
        ),
        GestureDetector(
          onTap: _seleccionarFoto,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _green.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    final initial = (widget.nombres.isNotEmpty)
        ? widget.nombres[0].toUpperCase()
        : '?';
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_light, _mid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          _loading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B2D8B)),
                  ),
                )
              : Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        children: [
                          _buildProfileTop(),
                          const SizedBox(height: 16),
                          if (_perfil?['clasificacion'] != null)
                            _buildClasificacionCard(),
                          const SizedBox(height: 16),
                          _buildDatosCard(),
                          const SizedBox(height: 20),
                          _buildBotones(),
                        ],
                      ),
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
          colors: [Color(0xFF3A1060), Color(0xFF6B2D8B), Color(0xFF9C4DBC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              // Back button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${_capitalizar(_primerNombre(widget.nombres))}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTop() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 12),
          Text(
            _formatearNombreCompleto(_perfil?['nombres'] ?? ''),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _mid.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _perfil?['rol'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: _mid,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClasificacionCard() {
    final clas = _perfil!['clasificacion'];
    final items = [
      {'icon': Icons.category_outlined, 'label': 'Categoría', 'value': clas['categoria']},
      {'icon': Icons.person_outline, 'label': 'Perfil', 'value': clas['perfil']},
      {'icon': Icons.bar_chart, 'label': 'Nivel', 'value': clas['nivel']},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green.withOpacity(0.85), const Color(0xFF5BA832)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['value'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatosCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _mid.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.assignment_ind_outlined, color: _mid, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Información personal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildCampoInfo(Icons.badge_outlined, 'DNI', _perfil?['dni'] ?? ''),
          _buildDivider(),
          _buildCampoEditable(
              Icons.phone_outlined, 'Teléfono', _telefonoController),
          _buildDivider(),
          _buildCampoEditable(
              Icons.email_outlined, 'Correo electrónico', _emailController),
          _buildDivider(),
          _buildCampoInfo(Icons.cake_outlined, 'Fecha de Nacimiento',
              _formatearFecha(_perfil?['fecha_nac'] ?? '')),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 56, endIndent: 16);

  Widget _buildCampoInfo(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: _mid, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(valor.isEmpty ? 'Sin datos' : valor,
                    style: TextStyle(
                        fontSize: 14,
                        color: _primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoEditable(
      IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _editando
          ? TextField(
              controller: controller,
              style: TextStyle(fontSize: 14, color: _primary),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: _mid, fontSize: 13),
                prefixIcon: Icon(icon, color: _mid, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _mid, width: 2),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            )
          : Row(
              children: [
                Icon(icon, color: _mid, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? 'Sin datos' : controller.text,
                        style: TextStyle(
                            fontSize: 14,
                            color: _primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (!_editando)
                  Icon(Icons.edit_outlined,
                      color: Colors.grey.shade400, size: 16),
              ],
            ),
    );
  }

    String _formatearFecha(String fecha) {
    if (fecha.isEmpty) return '';
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
    } catch (_) {}
    return fecha;
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  String _formatearNombreCompleto(String nombreCompleto) {
    if (nombreCompleto.isEmpty) return '';
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.length < 3) {
      return partes.map(_capitalizar).join(' ');
    }

    final apellidos = partes.sublist(0, 2);
    final nombres = partes.sublist(2);
    final reordenado = [...nombres, ...apellidos];
    return reordenado.map(_capitalizar).join(' ');
  }

  String _primerNombre(String nombreCompleto) {
    if (nombreCompleto.isEmpty) return nombreCompleto;
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.length >= 3) return partes[2];
    return partes.first; // fallback
  }

  Widget _buildBotones() {
    if (!_editando) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _editando = true),
          icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
          label: const Text('Editar información',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _mid,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            shadowColor: _mid.withOpacity(0.4),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _editando = false),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: Colors.white, size: 18),
              label: Text(_guardando ? 'Guardando...' : 'Guardar',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}