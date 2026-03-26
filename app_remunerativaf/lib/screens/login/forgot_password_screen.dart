import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _enviarOtp() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa tu correo.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/forgot-password/send-otp'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': _emailController.text.trim()}),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } else {
      final data = jsonDecode(response.body);
      setState(() => _error = data['message'] ?? 'Error al enviar el código.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B2D8B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Recuperar contraseña',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Ingresa tu correo registrado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Te enviaremos un código de 6 dígitos para restablecer tu contraseña.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xFF6B2D8B)),
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
                onPressed: _loading ? null : _enviarOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DC242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar código',
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