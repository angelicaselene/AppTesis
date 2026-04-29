import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home/valuacion_screen.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';

class UsuarioDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String nombres;

  const UsuarioDetalleScreen({
    super.key,
    required this.usuario,
    required this.nombres,
  });

  @override
  State<UsuarioDetalleScreen> createState() => _UsuarioDetalleScreenState();
}

class _UsuarioDetalleScreenState extends State<UsuarioDetalleScreen> {
  bool _reseteando = false;

  // ── Brand palette ──────────────────────────────────────────────
  static const Color _purple = Color(0xFF6B2D8B);
  static const Color _purpleLight = Color(0xFF9C4DBB);
  static const Color _purpleDark = Color(0xFF4A1D62);
  static const Color _green = Color(0xFF7DC242);
  static const Color _bg = Color(0xFFF4F0F8);
  // ───────────────────────────────────────────────────────────────

  Color _colorCategoria(String? categoria) {
    switch ((categoria ?? '').toUpperCase()) {
      case 'ESTRATÉGICOS': return const Color(0xFF7DC242);
      case 'ACADÉMICOS':   return const Color(0xFF6B2D8B);
      case 'TÁCTICOS':     return const Color(0xFF2196F3);
      case 'OPERATIVOS':   return const Color(0xFFFF9800);
      default:             return Colors.grey;
    }
  }

  Future<void> _confirmarReset() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset, color: Colors.red.shade600, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Resetear contraseña',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de resetear la contraseña de:',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.usuario['nombres'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _purple,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'La nueva contraseña será su número de DNI.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (widget.usuario['email'] == null ||
                widget.usuario['email'].toString().isEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Este usuario no tiene email. No recibirá notificación.',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sí, resetear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar == true) await _resetearPassword();
  }

  Future<void> _resetearPassword() async {
    setState(() => _reseteando = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/${widget.usuario['id']}/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (mounted) {
        final ok = response.statusCode == 200;
        final notificado = data['notificado'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: ok ? (notificado ? _green : Colors.orange) : Colors.red,
            content: Row(
              children: [
                Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ok
                        ? (notificado
                            ? 'Contraseña reseteada. Se notificó al usuario.'
                            : 'Contraseña reseteada. Sin email registrado.')
                        : (data['message'] ?? 'Error al resetear.'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red,
            content: const Text('Error de conexión.',
                style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reseteando = false);
    }
  }

  String _formatearFecha(String fecha) {
    if (fecha.isEmpty) return '—';
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
    } catch (_) {}
    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.usuario['clasificacion'];
    final categoria = c?['categoria'] as String?;
    final catColor = _colorCategoria(categoria);
    final nombre = widget.usuario['nombres'] ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(inicial, nombre, categoria, catColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Información Personal',
                    icon: Icons.person_outline_rounded,
                    iconColor: _purple,
                    child: _buildInfoGrid([
                      _InfoItem(Icons.badge_outlined, 'Nombre', nombre),
                      _InfoItem(Icons.email_outlined, 'Email',
                          widget.usuario['email'] ?? 'Sin email'),
                      _InfoItem(Icons.credit_card_outlined, 'DNI',
                          widget.usuario['dni'] ?? '—'),
                      _InfoItem(Icons.phone_outlined, 'Teléfono',
                          widget.usuario['telefono'] ?? 'Sin teléfono'),
                      _InfoItem(Icons.cake_outlined, 'Fecha Nac.',
                          _formatearFecha(widget.usuario['fecha_nac'] ?? '')),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Clasificación Jerárquica',
                    icon: Icons.account_tree_outlined,
                    iconColor: catColor,
                    child: _buildInfoGrid([
                      _InfoItem(Icons.work_outline_rounded, 'Cargo',
                          widget.usuario['cargo'] ?? 'Sin cargo'),
                      _InfoItem(Icons.category_outlined, 'Categoría',
                          categoria ?? 'N/A'),
                      _InfoItem(Icons.person_pin_outlined, 'Perfil',
                          c?['perfil'] ?? 'N/A'),
                      _InfoItem(Icons.layers_outlined, 'Nivel',
                          c?['nivel'] ?? 'N/A'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _buildRemuneracion(),
                  const SizedBox(height: 16),
                  _buildResetCard(),
                  const SizedBox(height: 20),
                  _buildSiguienteButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(
      String inicial, String nombre, String? categoria, Color catColor) {
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
        bottom: 20,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white38, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              inicial,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                if (categoria != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  // ── Info grid ─────────────────────────────────────────────────
  Widget _buildInfoGrid(List<_InfoItem> items) {
    return Column(
      children: items.map((item) => _buildInfoRow(item)).toList(),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 15, color: _purple),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Remuneración ──────────────────────────────────────────────
  Widget _buildRemuneracion() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purpleDark, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remuneración Mensual',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'S/ ${widget.usuario['remuneracion'] ?? '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reset card ────────────────────────────────────────────────
  Widget _buildResetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security_rounded,
                    color: Colors.red.shade600, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Gestión de Acceso',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Resetea la contraseña del usuario a su DNI por defecto. Se notificará si tiene email registrado.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _reseteando ? null : _confirmarReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                disabledBackgroundColor: Colors.red.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: _reseteando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_reset_rounded,
                      color: Colors.white, size: 18),
              label: Text(
                _reseteando ? 'Reseteando…' : 'Resetear contraseña al DNI',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón Siguiente ───────────────────────────────────────────
  Widget _buildSiguienteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ValuacionScreen(
              usuario: widget.usuario,
              nombres: widget.nombres,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          elevation: 2,
          shadowColor: _green.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.arrow_forward_rounded,
            color: Colors.white, size: 20),
        label: const Text(
          'Continuar a Valuación',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.3),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}