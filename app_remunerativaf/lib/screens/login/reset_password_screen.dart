import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  Future<void> _resetear() async {
    if (_passwordController.text.length < 8) {
      setState(() => _error = 'La contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/forgot-password/reset'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email':                 widget.email,
        'otp':                   widget.otp,
        'password':              _passwordController.text,
        'password_confirmation': _confirmController.text,
      }),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Contraseña actualizada! Inicia sesión.'),
            backgroundColor: Color(0xFF7DC242),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } else {
      final data = jsonDecode(response.body);
      setState(() => _error = data['message'] ?? 'Error al actualizar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B2D8B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Nueva contraseña',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Crea tu nueva contraseña',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Elige una contraseña segura de al menos 8 caracteres.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: _obscure1,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFF6B2D8B)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: _obscure2,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFF6B2D8B)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscure2 = !_obscure2),
                ),
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
                onPressed: _loading ? null : _resetear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DC242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cambiar contraseña',
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