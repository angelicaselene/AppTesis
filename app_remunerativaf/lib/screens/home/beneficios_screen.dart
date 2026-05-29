import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BeneficiosScreen extends StatefulWidget {
  final String nombres;
  final bool mostrarBotonAgregar;
  const BeneficiosScreen({
    super.key,
    required this.nombres,
    this.mostrarBotonAgregar = true,
  });

  @override
  State<BeneficiosScreen> createState() => _BeneficiosScreenState();
}

class _BeneficiosScreenState extends State<BeneficiosScreen> {
  Map<String, dynamic>? _perfil;
  bool _loading = true;
  final Set<int> _expandidos = {};

  static const List<Map<String, dynamic>> _beneficios = [
    {
      'titulo': 'Tiempo de Servicio',
      'icono': Icons.access_time_rounded,
      'color': Color(0xFF6B2D8B),
      'descripcion': 'Reconocimiento por lealtad y compromiso a largo plazo con la universidad.',
      'nota': 'Su otorgamiento es por única vez y no es retroactivo.',
      'columnas': ['Antigüedad', 'Bono'],
      'filas': [
        ['05 años', 'S/ 1 000.00'],
        ['10 años', 'S/ 2 500.00'],
        ['15 años', 'S/ 5 000.00'],
        ['20 años', 'S/ 5 000.00'],
        ['25 años', 'S/ 5 000.00'],
        ['30 años', 'S/ 5 000.00'],
      ],
    },
    {
      'titulo': 'Manejo de Idiomas',
      'icono': Icons.language_rounded,
      'color': Color(0xFF7DC242),
      'descripcion': 'Reconocimiento por dominar uno o más idiomas además de la lengua materna.',
      'nota': 'Condicionado a evaluación al máximo nivel. No aplica a docentes de Idiomas.',
      'columnas': ['Perfil', 'Bono'],
      'filas': [
        ['01 idioma', 'S/ 250.00'],
        ['02 idiomas', 'S/ 500.00'],
        ['03 idiomas', 'S/ 750.00'],
      ],
    },
    {
      'titulo': 'Productividad',
      'icono': Icons.trending_up_rounded,
      'color': Color(0xFF4A1570),
      'descripcion': 'Reconocimiento por rendimiento excepcional. Dirigido a Jefatura de Finanzas del Alumno y Call Center.',
      'nota': null,
      'columnas': ['Tipo', 'Meses', 'Incentivo', 'Meta'],
      'filas': [
        ['Bono Bimestral', 'Nov - Dic', 'S/ 300.00', '100% mensual'],
        ['Bono Anual', 'Ene - Dic', 'S/ 300.00', 'S/5,000,000'],
        ['Bono Anual', 'Ene - Dic', 'S/ 600.00', 'S/10,000,000'],
        ['Bono Extraordinario', 'Octubre', 'S/ 350.00', 'S/9,000,000'],
      ],
    },
    {
      'titulo': 'Cumplimiento de Metas',
      'icono': Icons.emoji_events_rounded,
      'color': Color(0xFF7DC242),
      'descripcion': 'Bono anual por logro de metas operativas, estratégicas y clima laboral.',
      'nota': null,
      'columnas': ['Puesto', 'Bono'],
      'filas': [
        ['1° Puesto', 'S/ 3 000.00'],
        ['2° Puesto', 'S/ 2 000.00'],
        ['3° Puesto', 'S/ 1 000.00'],
      ],
    },
    {
      'titulo': 'Categoría RENACYT',
      'icono': Icons.biotech_rounded,
      'color': Color(0xFF6B2D8B),
      'descripcion': 'Incentivo anual para personal docente y administrativo con nivel RENACYT.',
      'nota': 'No es retroactivo ni aplicable para Docentes Investigadores.',
      'columnas': ['Nivel', 'Bono', 'B. Reconoc.', 'B. Permanencia'],
      'filas': [
        ['NIVEL VII', 'S/ 500.00', '-', '-'],
        ['NIVEL VI', '-', 'S/ 1 500.00', 'S/ 500.00'],
        ['NIVEL V', '-', 'S/ 3 000.00', 'S/ 1 000.00'],
        ['NIVEL IV', '-', 'S/ 4 500.00', 'S/ 1 500.00'],
        ['NIVEL III', '-', 'S/ 6 000.00', 'S/ 2 000.00'],
        ['NIVEL II', '-', 'S/ 7 500.00', 'S/ 2 500.00'],
        ['NIVEL I', '-', 'S/ 9 000.00', 'S/ 3 000.00'],
        ['Inv. Distinguido', '-', 'S/ 10 500.00', 'S/ 3 500.00'],
      ],
    },
    {
      'titulo': 'Publicación Científica',
      'icono': Icons.article_rounded,
      'color': Color(0xFF4A1570),
      'descripcion': 'Incentivo por publicar trabajos en revistas científicas de alto impacto.',
      'nota': null,
      'columnas': ['Base', 'Descripción', 'Monto'],
      'filas': [
        ['SCOPUS', 'Q1 (SJR≥2)', 'S/ 8 000.00'],
        ['SCOPUS', 'Q1 (SJR<2)', 'S/ 4 000.00'],
        ['SCOPUS', 'Q2', 'S/ 3 000.00'],
        ['SCOPUS', 'Q3', 'S/ 2 000.00'],
        ['SCOPUS', 'Q4', 'S/ 1 000.00'],
        ['WOS', 'Q1 (JCI≥5)', 'S/ 8 000.00'],
        ['WOS', 'Q1 (JCI<5)', 'S/ 4 000.00'],
        ['WOS', 'Q2', 'S/ 3 000.00'],
        ['WOS', 'Q3', 'S/ 2 000.00'],
        ['WOS', 'Q4', 'S/ 1 000.00'],
        ['SCIELO', '-', 'S/ 500.00'],
      ],
    },
    {
      'titulo': 'Bonificación Especial',
      'icono': Icons.star_rounded,
      'color': Color(0xFF7DC242),
      'descripcion': 'El Docente Investigador tiene una bonificación especial del 50% de sus haberes totales.',
      'nota': null,
      'columnas': ['Beneficiario', 'Bono'],
      'filas': [
        ['Docente Investigador', '50% haberes totales'],
      ],
    },
    {
      'titulo': 'Ordinarización',
      'icono': Icons.workspace_premium_rounded,
      'color': Color(0xFF6B2D8B),
      'descripcion': 'Reconocimiento único por alcanzar categorías de Auxiliar, Asociado o Principal.',
      'nota': 'No es retroactivo. Pago hasta 3 meses tras la resolución.',
      'columnas': ['Categoría', 'Bono'],
      'filas': [
        ['Docentes Auxiliares', 'S/ 1 000.00'],
        ['Docentes Asociados', 'S/ 1 500.00'],
        ['Docentes Principales', 'S/ 2 000.00'],
      ],
    },
    {
      'titulo': 'Grado de Doctor',
      'icono': Icons.school_rounded,
      'color': Color(0xFF4A1570),
      'descripcion': 'Estímulo económico para personal docente y administrativo que alcance el grado de Doctor.',
      'nota': 'No es retroactivo.',
      'columnas': ['Colaborador', 'Incentivo'],
      'filas': [
        ['Docentes Tiempo Completo', 'S/ 500.00'],
        ['Administrativos Tiempo Completo', 'S/ 500.00'],
      ],
    },
    {
      'titulo': 'Incremento por Residencia',
      'icono': Icons.location_on_rounded,
      'color': Color(0xFF7DC242),
      'descripcion': 'Incremento salarial a docentes que viven en sedes distintas a su lugar de trabajo.',
      'nota': 'No es retroactivo.',
      'columnas': ['Categoría', 'Chiclayo', 'Lima', 'Piura/Trujillo'],
      'filas': [
        ['T. Completo', 'S/ 300', 'S/ 500', 'S/ 300'],
        ['T. Parcial', 'S/ 3.00', 'S/ 5.00', 'S/ 3.00'],
      ],
    },
    {
      'titulo': 'Grados Adicionales',
      'icono': Icons.menu_book_rounded,
      'color': Color(0xFF6B2D8B),
      'descripcion': 'Incremento salarial por grados adicionales al requerido por el MOF, en universidades top 500 mundial.',
      'nota': 'No es retroactivo.',
      'columnas': ['Grado', 'T. Completo', 'T. Parcial'],
      'filas': [
        ['Título Universitario', 'S/ 200.00', 'S/ 2.00'],
        ['Segunda Especialidad', 'S/ 300.00', 'S/ 3.00'],
        ['Maestría', 'S/ 400.00', 'S/ 4.00'],
        ['Doctorado', 'S/ 500.00', 'S/ 4.00'],
      ],
    },
    {
      'titulo': 'Bonif. por Jubilación',
      'icono': Icons.elderly_rounded,
      'color': Color(0xFF4A1570),
      'descripcion': 'Bono económico para colaboradores que se jubilan entre los 65 y 70 años.',
      'nota': null,
      'columnas': ['Años de servicio', 'Bono'],
      'filas': [
        ['De 10 a 20 años', 'S/ 10 000.00'],
        ['De 20 años a más', 'S/ 20 000.00'],
      ],
    },
    {
      'titulo': 'Aux. de Transporte',
      'icono': Icons.directions_car_rounded,
      'color': Color(0xFF7DC242),
      'descripcion': 'Incremento remunerativo para auxiliares de transporte según nivel de responsabilidad.',
      'nota': null,
      'columnas': ['Clasificación', 'Mínimo', 'Máximo'],
      'filas': [
        ['Presidencia Ejecutiva', 'S/ 1 000.00', 'S/ 1 300.00'],
        ['Directorio', 'S/ 600.00', 'S/ 800.00'],
        ['Rectorado / Gerencia', 'S/ 400.00', 'S/ 500.00'],
      ],
    },
    {
      'titulo': 'Fallecimiento Familiar',
      'icono': Icons.favorite_rounded,
      'color': Color(0xFF6B2D8B),
      'descripcion': 'Beneficio económico único por fallecimiento de familiar directo.',
      'nota': 'Requiere al menos 6 meses de servicio y documentación.',
      'columnas': ['Clasificación', 'Monto'],
      'filas': [
        ['Docente T. Completo', 'S/ 3 000.00'],
        ['Administrativo T. Completo', 'S/ 3 000.00'],
      ],
    },
    {
      'titulo': 'Descuento Estudios USS',
      'icono': Icons.local_library_rounded,
      'color': Color(0xFF4A1570),
      'descripcion': 'Descuento especial en estudios de Pregrado y Posgrado de la USS para el trabajador y su familia.',
      'nota': 'Aplica a personal a tiempo completo. No aplica para Medicina Humana.',
      'columnas': ['Estudios', 'Beneficiario', 'Descuento'],
      'filas': [
        ['Pregrado', 'Trabajador', 'Categoría II'],
        ['Pregrado', 'Hijo / Cónyuge', 'Categoría II'],
        ['Posgrado', 'Trabajador', '25%'],
        ['Posgrado', 'Hijo / Cónyuge', '25%'],
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await ApiService.getPerfil();
    setState(() {
      _perfil = data;
      _loading = false;
    });
  }

  String _formatearNombre(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.length >= 3) {
      final nombre = partes[2][0].toUpperCase() + partes[2].substring(1).toLowerCase();
      final apellido = partes[0][0].toUpperCase() + partes[0].substring(1).toLowerCase();
      return '$nombre $apellido';
    }
    return nombreCompleto;
  }

  @override
  Widget build(BuildContext context) {
    final clasificacion = _perfil?['clasificacion'];
    final contrato = _perfil?['contrato'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      body: Column(
        children: [
          _buildHeader(context, clasificacion, contrato),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B2D8B)))
                : _buildLista(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic clasificacion, dynamic contrato) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A1060), Color(0xFF6B2D8B), Color(0xFF9C4DBC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.nombres.isNotEmpty ? widget.nombres[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, ${_formatearNombre(widget.nombres)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const Text('Beneficios USS',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (widget.mostrarBotonAgregar)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DC242),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7DC242).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
            ],
          ),
          if (!_loading && clasificacion != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    contrato?['cargo'] ?? 'Sin cargo',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DC242).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${clasificacion['categoria'] ?? ''} · ${clasificacion['nivel'] ?? ''}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLista() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título sección
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                    color: const Color(0xFF6B2D8B),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mis Beneficios USS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3A1060))),
                    Text('Toca un beneficio para ver el detalle',
                        style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
              if (widget.mostrarBotonAgregar)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DC242),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: const Color(0xFF7DC242).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de beneficios expandibles
          for (int i = 0; i < _beneficios.length; i++) ...[
            _buildBeneficioCard(i),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildBeneficioCard(int i) {
    final b = _beneficios[i];
    final color = b['color'] as Color;
    final isOpen = _expandidos.contains(i);

    return GestureDetector(
      onTap: () => setState(() {
        if (isOpen) {
          _expandidos.remove(i);
        } else {
          _expandidos.add(i);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isOpen ? 0.18 : 0.08),
              blurRadius: isOpen ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Barra de color superior
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.5)],
                  ),
                ),
              ),
              // Header del card — siempre visible
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isOpen ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(b['icono'] as IconData, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        b['titulo'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF2D1040)),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: color, size: 22),
                    ),
                  ],
                ),
              ),
              // Contenido desplegable
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: isOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildDetalleInline(b, color),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleInline(Map<String, dynamic> b, Color color) {
    final columnas = b['columnas'] as List;
    final filas = b['filas'] as List;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: color.withOpacity(0.15), height: 1),
          const SizedBox(height: 12),

          // Descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: color, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b['descripcion'],
                    style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.9),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tabla
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      for (final col in columnas)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 9),
                            child: Text(col,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                                textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  ),
                ),
                // Filas
                for (int r = 0; r < filas.length; r++)
                  Container(
                    decoration: BoxDecoration(
                      color: r.isEven ? Colors.white : color.withOpacity(0.04),
                      border: r < filas.length - 1
                          ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                          : null,
                    ),
                    child: Row(
                      children: [
                        for (int c = 0; c < (filas[r] as List).length; c++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 9),
                              child: Text(
                                (filas[r] as List)[c],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c == (filas[r] as List).length - 1
                                      ? color
                                      : const Color(0xFF2D1040),
                                  fontWeight: c == (filas[r] as List).length - 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Nota
          if (b['nota'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: color, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b['nota'],
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontStyle: FontStyle.italic,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}