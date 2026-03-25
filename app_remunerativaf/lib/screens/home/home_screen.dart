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

class _HomeScreenState extends State<HomeScreen> {
  int totalUsuarios = 0;
  int totalPuestos = 0;
  String nombres = '';
  bool _loading = true;
  bool _subiendoExcel = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Excel importado'),
          backgroundColor: response['message'] != null
              ? const Color(0xFF7DC242)
              : Colors.red,
        ),
      );
      // Recargar indicadores
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
                  'Hola ${nombres.split(' ').first}',
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
                    // Indicadores
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
                            'Indicadores Clave de RR.HH',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(children: [
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
                              ]),
                              Column(children: [
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
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón cargar Excel
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _subiendoExcel ? null : _cargarExcel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DC242),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _subiendoExcel
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                        label: Text(
                          _subiendoExcel ? 'Importando...' : 'Cargar Excel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Módulos de Gestión',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildModulo('Gestión Usuarios', Icons.people_outline, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UsuariosScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Clasificación de puestos', Icons.account_tree_outlined, () {
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
                        _buildModulo('Visualización de escalas', Icons.bar_chart_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EscalaScreen(nombres: nombres),
                            ),
                          );
                        }),
                        _buildModulo('Beneficios', Icons.card_giftcard_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BeneficiosScreen(nombres: nombres),
                            ),
                          );
                        }),
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
            Icon(icono, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}