import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../home/usuarios_screen.dart';
import '../mof/mof_screen.dart';
import '../perfil/perfil_screen.dart';
import '../perfil/calibracion_screen.dart';
import '../home/valorizacion_screen.dart';
import '../home/escala_screen.dart';
import 'analisis_salarial_screen.dart';
// ignore: unused_import
import 'detalle_escala_screen.dart';


class DirectorioScreen extends StatefulWidget {
  const DirectorioScreen({super.key});

  @override
  State<DirectorioScreen> createState() => _DirectorioScreenState();
}

class _DirectorioScreenState extends State<DirectorioScreen> {
  int totalPuestos = 0;
  int totalUsuarios = 0;
  String nombres = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final indicadores = await ApiService.getIndicadores();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPuestos = indicadores['total_puestos'] ?? 0;
      totalUsuarios = indicadores['total_usuarios'] ?? 0;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hola ${nombres.split(' ').last}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PerfilScreen(nombres: nombres),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _logout,
                    ),
                  ],
                ),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Indicadores Clave de Directorio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '$totalUsuarios',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B2D8B),
                                    ),
                                  ),
                                  const Text(
                                    'Usuarios',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$totalPuestos',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7DC242),
                                    ),
                                  ),
                                  const Text(
                                    'PUESTOS (MOF)',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Funciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                      children: [
                        _buildModulo('Gestión Usuario', Icons.person_outline, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UsuariosScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Clasificación de Puestos', Icons.help_outline, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MofScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Calibración de Factores', Icons.tune_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalibracionScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Valorización', Icons.calculate_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ValorizacionScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Análisis Salarial', Icons.manage_accounts_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnalisisSalarialScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Visualización de escalas', Icons.bar_chart_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EscalaScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Detalle de Escalas', Icons.table_chart_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleEscalaScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Reportes', Icons.insert_chart_outlined, () {}),
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

  Widget _buildModulo(String titulo, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6B2D8B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: const Color(0xFF7DC242), size: 36),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}