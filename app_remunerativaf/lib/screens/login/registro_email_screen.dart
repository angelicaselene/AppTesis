import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../directorio/directorio_screen.dart';
import '../trabajador/trabajador_screen.dart';

class RegistroEmailScreen extends StatefulWidget {
  final String rol;
  const RegistroEmailScreen({super.key, required this.rol});

  @override
  State<RegistroEmailScreen> createState() => _RegistroEmailScreenState();
}

class _RegistroEmailScreenState extends State<RegistroEmailScreen> {
  final _emailController    = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _registrar() async {
    if (_emailController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/registro-email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email':    _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      }),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        Widget destino;
        if (widget.rol == 'DIR') {
          destino = const DirectorioScreen();
        } else if (widget.rol == 'TRAB') {
          destino = const TrabajadorScreen();
        } else {
          destino = const HomeScreen();
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destino),
          (_) => false,
        );
      }
    } else {
      final data = jsonDecode(response.body);
      setState(() => _error = data['message'] ?? 'Error al guardar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B2D8B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.email_outlined,
                    color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                '¡Bienvenido al sistema!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Para continuar, registra tu correo y teléfono.\nEsto te permitirá recuperar tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Correo electrónico',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'ejemplo@gmail.com',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xFF6B2D8B)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Teléfono',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '987654321',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: Color(0xFF6B2D8B)),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DC242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar y continuar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}