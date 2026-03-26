import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import 'registro_contacto_screen.dart';

class CambiarPasswordScreen extends StatefulWidget {
  final String rol;
  final String dni;

  const CambiarPasswordScreen({
    super.key,
    required this.rol,
    required this.dni,
  });

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _loading  = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  Future<void> _cambiar() async {
    setState(() => _error = null);

    if (_passwordController.text.length < 8) {
      setState(() => _error = 'La contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (_passwordController.text == widget.dni) {
      setState(() => _error = 'La contraseña no puede ser igual a tu DNI.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/primer-ingreso/cambiar-password'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password':              _passwordController.text,
          'password_confirmation': _confirmController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegistroContactoScreen(rol: widget.rol),
            ),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['message'] ?? 'Error al cambiar contraseña.');
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
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Crea tu contraseña',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Por seguridad, debes cambiar tu contraseña\nantes de continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              // Indicador de pasos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepIndicator(1, activo: true, completado: false),
                  const SizedBox(width: 8),
                  _stepIndicator(2, activo: false, completado: false),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Nueva contraseña',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B2D8B)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Confirmar contraseña',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  hintText: 'Repite tu contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B2D8B)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
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
                  onPressed: _loading ? null : _cambiar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DC242),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continuar',
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