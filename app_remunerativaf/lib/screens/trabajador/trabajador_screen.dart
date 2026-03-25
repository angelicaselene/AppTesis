import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../perfil/perfil_screen.dart';
// ignore: unused_import
import 'mi_puesto_salario_screen.dart';
// ignore: unused_import
import 'valoracion_puestos_screen.dart';
// ignore: unused_import
import '../home/beneficios_screen.dart';



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
      final nombre = partes[2][0].toUpperCase() +
          partes[2].substring(1).toLowerCase();
      final apellido = partes[0][0].toUpperCase() +
          partes[0].substring(1).toLowerCase();
      return '$nombre $apellido';
    } else if (partes.length == 2) {
      return partes
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join(' ');
    }
    return nombreCompleto;
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];

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
                Expanded(
                  child: Text(
                    'Hola, ${_formatearNombre(nombres)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                    // Card puesto actual
                    Container(
                      width: double.infinity,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Puesto Actual',
                              style: TextStyle(
                                color: Color(0xFF7DC242),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contrato?['cargo'] ?? 'Sin cargo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Categoría: ${clasificacion?['categoria'] ?? 'N/A'} - ${clasificacion?['perfil'] ?? ''} ${clasificacion?['nivel'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título portal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Mi Portal Remunerativo USS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Módulos
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildModulo(
                          'Mi puesto y salario',
                          Icons.person_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MiPuestoSalarioScreen(nombres: nombres),
                              ),
                            );
                          },
                        ),
                        _buildModulo(
                          'Valoración de puestos',
                          Icons.star_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ValoracionPuestosScreen(nombres: nombres),
                              ),
                            );
                          },
                        ),
                        _buildModulo(
                          'Mi historial',
                          Icons.article_outlined,
                          () {},
                        ),
                        _buildModulo(
                          'Beneficios',
                          Icons.diamond_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BeneficiosScreen(
                                  nombres: nombres,
                                  mostrarBotonAgregar: false,
                                ),
                              ),
                            );
                          },
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
            Icon(icono, color: const Color(0xFF7DC242), size: 40),
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