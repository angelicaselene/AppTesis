import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../directorio/directorio_screen.dart';
import '../trabajador/trabajador_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await AuthService.getToken();
    if (mounted) {
      if (token != null) {
        final rol = await AuthService.getRol();
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
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7DC242),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_uss.png', width: 200),
            const SizedBox(height: 16),
            const Text(
              'BIENVENIDO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}