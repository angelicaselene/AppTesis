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

class _TrabajadorScreenState extends State<TrabajadorScreen> {
  Map<String, dynamic>? _perfil;
  String nombres = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final perfil = await ApiService.getPerfil();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfil = perfil;
      nombres = prefs.getString('nombres') ?? '';
      _loading = false;
    });
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
    final contrato = _perfil?['contrato'];
    final salario = contrato?['remuneracion'] ?? '0.00';

    return Scaffold(
      backgroundColor: const Color(0xFFF0EDF5),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A1570), Color(0xFF6B2D8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, right: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bienvenido,', style: TextStyle(color: Colors.white60, fontSize: 13)),
                        Text(
                          _formatearNombre(nombres),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _headerBtn(Icons.person_outline, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilScreen(nombres: nombres)));
                        }),
                        const SizedBox(width: 8),
                        _headerBtn(Icons.logout_rounded, _logout),
                      ],
                    ),
                  ],
                ),
                if (!_loading) ...[
                  const SizedBox(height: 16),
                  // Info rápida en el header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _headerInfo(
                            Icons.work_outline,
                            'Puesto',
                            contrato?['cargo'] ?? 'N/A',
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        Expanded(
                          child: _headerInfo(
                            Icons.attach_money,
                            'Salario',
                            'S/ $salario',
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        Expanded(
                          child: _headerInfo(
                            Icons.workspace_premium_outlined,
                            'Nivel',
                            '${clasificacion?['nivel'] ?? 'N/A'}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título sección
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mi Portal Remunerativo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D1040))),
                          Text('USS · Selecciona una opción', style: TextStyle(fontSize: 12, color: Colors.black45)),
                        ],
                      ),
                    ),

                    // Grid de módulos
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [
                        _moduloCard(
                          titulo: 'Mi Puesto y Salario',
                          subtitulo: 'Posición y banda salarial',
                          icono: Icons.payments_outlined,
                          colorIcon: const Color(0xFF7DC242),
                          colorBg: const Color(0xFFEEF7E5),
                          colorCard: const Color(0xFF6B2D8B),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MiPuestoSalarioScreen(nombres: nombres))),
                        ),
                        _moduloCard(
                          titulo: 'Valoración de Puestos',
                          subtitulo: 'Puntos y factores',
                          icono: Icons.star_outline_rounded,
                          colorIcon: const Color(0xFF7DC242),
                          colorBg: const Color(0xFFEEF7E5),
                          colorCard: const Color(0xFF4A1570),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValoracionPuestosScreen(nombres: nombres))),
                        ),
                        _moduloCard(
                          titulo: 'Mi Historial',
                          subtitulo: 'Evolución salarial',
                          icono: Icons.timeline_outlined,
                          colorIcon: const Color(0xFF7DC242),
                          colorBg: const Color(0xFFEEF7E5),
                          colorCard: const Color(0xFF6B2D8B),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistorialScreen(nombres: nombres))),
                        ),
                        _moduloCard(
                          titulo: 'Beneficios',
                          subtitulo: 'Beneficios laborales',
                          icono: Icons.card_giftcard_outlined,
                          colorIcon: const Color(0xFF7DC242),
                          colorBg: const Color(0xFFEEF7E5),
                          colorCard: const Color(0xFF4A1570),
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BeneficiosScreen(nombres: nombres, mostrarBotonAgregar: false),
                          )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Card departamento
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
  ),
  child: Column(
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business_outlined, color: Color(0xFF6B2D8B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Departamento', style: TextStyle(fontSize: 11, color: Colors.black45)),
                Text(
                  contrato?['departamento'] ?? 'N/A',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D1040)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Divider(height: 1),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF7DC242), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo de Contrato', style: TextStyle(fontSize: 11, color: Colors.black45)),
                Text(
                  contrato?['tipo_contrato'] ?? 'N/A',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7DC242)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
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

  Widget _headerBtn(IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _headerInfo(IconData icono, String label, String valor) {
    return Column(
      children: [
        Icon(icono, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _moduloCard({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorIcon,
    required Color colorBg,
    required Color colorCard,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorCard, colorCard.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: colorCard.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            // Círculo decorativo
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icono, color: colorIcon, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(subtitulo, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}