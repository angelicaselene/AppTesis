import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../perfil/perfil_screen.dart';
import 'mi_puesto_salario_screen.dart';
import 'valoracion_puestos_screen.dart';
import '../home/beneficios_screen.dart';
import 'historial_screen.dart';

class TrabajadorScreen extends StatefulWidget {
  const TrabajadorScreen({super.key});

  @override
  State<TrabajadorScreen> createState() => _TrabajadorScreenState();
}

class _TrabajadorScreenState extends State<TrabajadorScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _perfil;
  String nombres = '';
  bool _loading = true;

  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  static const Color _purple     = Color(0xFF6B2D8B);
  static const Color _purpleLight = Color(0xFF9C4DBB);
  static const Color _purpleDark  = Color(0xFF4A1D62);
  static const Color _green      = Color(0xFF7DC242);
  static const Color _greenDark  = Color(0xFF5A9B2A);
  static const Color _bg         = Color(0xFFF4F0F8);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController!, curve: Curves.easeOut);
    _cargarDatos();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final perfil = await ApiService.getPerfil();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfil = perfil;
      nombres = prefs.getString('nombres') ?? '';
      _loading = false;
    });
    _animController?.forward();
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

  String _formatearNombre(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.length >= 3) {
      final nombre = partes[2][0].toUpperCase() + partes[2].substring(1).toLowerCase();
      final apellido = partes[0][0].toUpperCase() + partes[0].substring(1).toLowerCase();
      return '$nombre $apellido';
    } else if (partes.length == 2) {
      return partes.map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase()).join(' ');
    }
    return nombreCompleto;
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato     = _perfil?['contrato'];
    final salario      = contrato?['remuneracion'] ?? '0.00';

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(clasificacion, contrato, salario),
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
                      _buildIndicadores(clasificacion, contrato, salario),
                      const SizedBox(height: 16),
                      _buildSectionLabel('Mi Portal Remunerativo'),
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

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(dynamic clasificacion, dynamic contrato, dynamic salario) {
    final firstName = _formatearNombre(nombres).split(' ').first;
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
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white38, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Portal del Trabajador · USS',
                  style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PerfilScreen(nombres: nombres))),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  // ─── INDICADORES ───────────────────────────────────────────────────────────
  Widget _buildIndicadores(dynamic clasificacion, dynamic contrato, dynamic salario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                width: 4, height: 18,
                decoration: BoxDecoration(
                    color: _purple, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mi Información',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: 'S/ $salario',
                  label: 'Mi Salario',
                  icon: Icons.attach_money_rounded,
                  color: _purple,
                  bgColor: _purple.withOpacity(0.08),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  value: clasificacion?['nivel'] ?? 'N/A',
                  label: 'Mi Nivel',
                  icon: Icons.workspace_premium_rounded,
                  color: _green,
                  bgColor: _green.withOpacity(0.09),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Puesto y categoría
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.work_outline_rounded,
                          color: _purple, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        contrato?['cargo'] ?? 'Sin cargo asignado',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Badge categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        clasificacion?['categoria'] ?? '',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _purple),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge tipo contrato — flexible para no desbordar
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          contrato?['tipo_contrato'] ?? '',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _greenDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.75),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION LABEL ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              color: _purple, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A1A2E)),
        ),
      ],
    );
  }

  // ─── GRID ──────────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    final modulos = [
      _ModuloData(
        titulo: 'Mi Puesto\ny Salario',
        icono: Icons.payments_outlined,
        color: _purple,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => MiPuestoSalarioScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Valoración\nde Puestos',
        icono: Icons.star_outline_rounded,
        color: _purpleDark,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ValoracionPuestosScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Mi Historial',
        icono: Icons.timeline_outlined,
        color: _purpleLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => HistorialScreen(nombres: nombres))),
      ),
      _ModuloData(
        titulo: 'Beneficios',
        icono: Icons.card_giftcard_outlined,
        color: _green,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => BeneficiosScreen(nombres: nombres, mostrarBotonAgregar: false))),
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth   = (screenWidth - 40 - 14) / 2;
    final cardHeight  = cardWidth / 1.55;

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
      itemBuilder: (_, i) => _buildModuloCard(modulos[i]),
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
        child: Stack(
          children: [
            Positioned(
              right: -15, top: -15,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
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
                      height: 1.3),
                ),
              ],
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