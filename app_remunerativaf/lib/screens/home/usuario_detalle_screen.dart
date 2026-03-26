import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home/valuacion_screen.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';

class UsuarioDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String nombres;

  const UsuarioDetalleScreen({
    super.key,
    required this.usuario,
    required this.nombres,
  });

  @override
  State<UsuarioDetalleScreen> createState() => _UsuarioDetalleScreenState();
}

class _UsuarioDetalleScreenState extends State<UsuarioDetalleScreen> {
  bool _reseteando = false;

  Future<void> _confirmarReset() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Color(0xFF6B2D8B)),
            SizedBox(width: 8),
            Text(
              'Resetear contraseña',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de resetear la contraseña de:',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.usuario['nombres'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B2D8B),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'La nueva contraseña será su número de DNI.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (widget.usuario['email'] == null ||
                widget.usuario['email'].toString().isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Este usuario no tiene email. No recibirá notificación.',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2D8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sí, resetear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _resetearPassword();
    }
  }

  Future<void> _resetearPassword() async {
    setState(() => _reseteando = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/usuarios/${widget.usuario['id']}/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        if (response.statusCode == 200) {
          final notificado = data['notificado'] == true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notificado
                          ? 'Contraseña reseteada. Se notificó al usuario por email.'
                          : 'Contraseña reseteada. El usuario no tiene email registrado.',
                    ),
                  ),
                ],
              ),
              backgroundColor:
                  notificado ? const Color(0xFF7DC242) : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Error al resetear.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reseteando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.usuario['clasificacion'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6B2D8B),
            padding: const EdgeInsets.only(
              top: 50, left: 20, right: 20, bottom: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Hola ${widget.nombres.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de usuario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _campo(widget.usuario['nombres'] ?? ''),
                        _campo(widget.usuario['email'] ?? 'Sin email'),
                        _campo(widget.usuario['dni'] ?? ''),
                        _campo(widget.usuario['telefono'] ?? 'Sin teléfono'),
                        _campo(widget.usuario['fecha_nac'] ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Clasificación Jerárquica',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _campo(widget.usuario['cargo'] ?? 'Sin cargo'),
                        _campo('Categoría: ${c?['categoria'] ?? 'N/A'}'),
                        _campo('Perfil: ${c?['perfil'] ?? 'N/A'}'),
                        _campo('Nivel: ${c?['nivel'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Remuneración
                  const Text(
                    'Remuneración',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFF6B2D8B), width: 6,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remuneración Mensual',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF6B2D8B),
                          ),
                        ),
                        Text(
                          'S/ ${widget.usuario['remuneracion'] ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF6B2D8B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón resetear contraseña
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: Colors.red, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Gestión de acceso',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Resetea la contraseña del usuario a su DNI por defecto. Se notificará al usuario si tiene email registrado.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _reseteando ? null : _confirmarReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: _reseteando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.lock_reset,
                                    color: Colors.white, size: 18),
                            label: Text(
                              _reseteando
                                  ? 'Reseteando...'
                                  : 'Resetear contraseña al DNI',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón siguiente (valuación)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ValuacionScreen(
                              usuario: widget.usuario,
                              nombres: widget.nombres,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DC242),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Siguiente',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        valor,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}