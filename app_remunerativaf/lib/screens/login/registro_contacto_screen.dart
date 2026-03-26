import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../directorio/directorio_screen.dart';
import '../trabajador/trabajador_screen.dart';

class RegistroContactoScreen extends StatefulWidget {
  final String rol;
  const RegistroContactoScreen({super.key, required this.rol});

  @override
  State<RegistroContactoScreen> createState() => _RegistroContactoScreenState();
}

class _RegistroContactoScreenState extends State<RegistroContactoScreen> {
  final _emailController    = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _registrar() async {
    setState(() => _error = null);

    if (_emailController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty) {
      setState(() => _error = 'Todos los campos son obligatorios.');
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/primer-ingreso/registrar-contacto'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email':    _emailController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        }),
      );

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
    } catch (e) {
      setState(() => _error = 'Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B2D8B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.contact_mail_outlined,
                      color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Registra tus datos de contacto',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Los necesitamos para poder recuperar\ntu contraseña en el futuro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              // Indicador de pasos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepIndicator(1, activo: false, completado: true),
                  const SizedBox(width: 8),
                  _stepIndicator(2, activo: true, completado: false),
                ],
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: Color(0xFF6B2D8B)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
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
                      : const Text('Finalizar y entrar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int numero, {required bool activo, required bool completado}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completado
            ? const Color(0xFF7DC242)
            : activo
                ? const Color(0xFF6B2D8B)
                : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: completado
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '$numero',
                style: TextStyle(
                  color: activo ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}