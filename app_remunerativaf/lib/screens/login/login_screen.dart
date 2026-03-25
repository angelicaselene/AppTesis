import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../directorio/directorio_screen.dart';
import '../trabajador/trabajador_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.login(
      _dniController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (result['status'] == 200) {
      if (mounted) {
        final rol = result['data']['user']['rol'];
        if (rol == 'DIR') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DirectorioScreen()),
          );
        } else if (rol == 'TRAB') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrabajadorScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } else {
      setState(
        () => _error = result['data']['message'] ?? 'Error al iniciar sesión',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: 16,
            child: Image.asset(
              'assets/sello_certificacion.png',
              width: 70,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Image.asset('assets/logo_uss.png', width: 220),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Gestión Remunerativa',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Usuario',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'DNI',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Contraseña',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••••••••••',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DC242),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'INGRESAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Olvidó su contraseña?',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}