import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../mof/mof_screen.dart';
import '../perfil/perfil_screen.dart';
import '../perfil/calibracion_screen.dart';
import 'usuarios_screen.dart';
import 'valorizacion_screen.dart';
import 'beneficios_screen.dart';
import 'escala_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int totalUsuarios = 0;
  int totalPuestos = 0;
  String nombres = '';
  bool _loading = true;
  bool _subiendoExcel = false;
  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  static const Color _purple = Color(0xFF6B2D8B);
  static const Color _purpleLight = Color(0xFF9C4DBB);
  static const Color _purpleDark = Color(0xFF4A1D62);
  static const Color _green = Color(0xFF7DC242);
  static const Color _greenDark = Color(0xFF5A9B2A);
  static const Color _bg = Color(0xFFF4F0F8);
  static const Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOut,
    );
    _cargarDatos();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final indicadores = await ApiService.getIndicadores();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalUsuarios = indicadores['total_usuarios'] ?? 0;
      totalPuestos = indicadores['total_puestos'] ?? 0;
      nombres = prefs.getString('nombres') ?? '';
      _loading = false;
    });
    _animController?.forward();
  }

  Future<void> _cargarExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;

    setState(() => _subiendoExcel = true);
    final response = await ApiService.importarExcel(filePath);
    setState(() => _subiendoExcel = false);

    if (mounted) {
      final ok = response['message'] != null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: ok ? _green : Colors.redAccent,
          content: Row(
            children: [
              Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
                  color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  response['message'] ?? 'Error al importar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
      _cargarDatos();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  String _formatearPrimerNombre(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    final nombre = partes.length >= 3 ? partes[2] : partes.first;
    return nombre[0].toUpperCase() + nombre.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: _purple)),
            )
          else
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIndicadores(),
                      const SizedBox(height: 16),
                      _buildExcelButton(),
                      const SizedBox(height: 16),
                      _buildSectionLabel('Módulos de Gestión'),
                      const SizedBox(height: 20),
                      _buildGrid(),
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
    final firstName = _formatearPrimerNombre(nombres);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_purpleDark, _purple, _purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 12,
        bottom: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white38, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $firstName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Panel de Administración RR.HH',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined, color: Colors.white),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PerfilScreen(nombres: nombres)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadores() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Indicadores Clave de RR.HH',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '$totalUsuarios',
                  label: 'Usuarios',
                  icon: Icons.people_alt_rounded,
                  color: _purple,
                  bgColor: _purple.withOpacity(0.08),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  value: '$totalPuestos',
                  label: 'Puestos (MOF)',
                  icon: Icons.account_tree_rounded,
                  color: _green,
                  bgColor: _green.withOpacity(0.09),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExcelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _subiendoExcel ? null : _cargarExcel,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: _green.withOpacity(0.55),
          elevation: 2,
          shadowColor: _green.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _subiendoExcel
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.upload_file_rounded, color: Colors.white, size: 22),
        label: Text(
          _subiendoExcel ? 'Importando…' : 'Cargar Excel',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final modulos = [
      _ModuloData(
        titulo: 'Gestión\nUsuarios',
        icono: Icons.people_rounded,
        color: _purple,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => UsuariosScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Clasificación\nde Puestos',
        icono: Icons.account_tree_rounded,
        color: _purpleDark,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => MofScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Calibración\nde Factores',
        icono: Icons.tune_rounded,
        color: _purpleLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CalibracionScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Valorización',
        icono: Icons.calculate_rounded,
        color: _green,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ValorizacionScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Visualización\nde Escalas',
        icono: Icons.bar_chart_rounded,
        color: _greenDark,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => EscalaScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Beneficios',
        icono: Icons.card_giftcard_rounded,
        color: const Color(0xFFE07B39),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => BeneficiosScreen(nombres: nombres))),
      ),
    ];

    // Altura fija calculada en base al ancho real de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40 - 14) / 2;
    final cardHeight = cardWidth / 1.55;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: cardHeight,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modulos.length,
      itemBuilder: (context, i) => _buildModuloCard(modulos[i]),
    );
  }

  Widget _buildModuloCard(_ModuloData m) {
    return GestureDetector(
      onTap: m.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [m.color, m.color.withOpacity(0.78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: m.color.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(m.icono, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              m.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuloData {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  const _ModuloData({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}
