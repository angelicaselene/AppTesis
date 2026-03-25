import 'package:flutter/material.dart';
import '../home/valuacion_screen.dart';

class UsuarioDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String nombres;

  const UsuarioDetalleScreen({
    super.key,
    required this.usuario,
    required this.nombres,
  });

  @override
  Widget build(BuildContext context) {
    final c = usuario['clasificacion'];

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
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Hola ${nombres.split(' ').first}',
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
                        _campo(usuario['nombres'] ?? ''),
                        _campo(usuario['email'] ?? 'Sin email'),
                        _campo(usuario['dni'] ?? ''),
                        _campo(usuario['telefono'] ?? 'Sin teléfono'),
                        _campo(usuario['fecha_nac'] ?? ''),
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
                        _campo(usuario['cargo'] ?? 'Sin cargo'),
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
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFF6B2D8B),
                          width: 6,
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
                          'S/ ${usuario['remuneracion'] ?? '0.00'}',
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ValuacionScreen(
                              usuario: usuario,
                              nombres: nombres,
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