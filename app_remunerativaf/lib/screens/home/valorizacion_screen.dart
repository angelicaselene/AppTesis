import 'package:flutter/material.dart';

class ValorizacionScreen extends StatefulWidget {
  final String nombres;
  const ValorizacionScreen({super.key, required this.nombres});

  @override
  State<ValorizacionScreen> createState() => _ValorizacionScreenState();
}

class _ValorizacionScreenState extends State<ValorizacionScreen> {
  // Mapa de estado expandido por clave "factorIndex-subfactorIndex"
  final Map<String, bool> _expanded = {};

  static const List<Map<String, dynamic>> _factores = [
    {
      'factor': 'CALIFICACIONES Y COMPETENCIAS',
      'subfactores': [
        {
          'nombre': 'Formación Profesional',
          'descripcion': 'Valora los conocimientos académicos necesarios para ejercer con efectividad las responsabilidades de un puesto y alcanzar los resultados previstos.',
          'niveles': ['Doctorado - PHD', 'Maestría (as)', 'Titulado', 'Bachiller Universitario', 'Técnico o menos'],
        },
        {
          'nombre': 'Investigación',
          'descripcion': 'Valora los aportes de investigacion que son necesarios para ejercer con efectividad las responsabilidades de un puesto y alcanzar los resultados previstos por la Universidad.',
          'niveles': [
            'Es Renacyt, filia por la Universidad y realiza investigaciones (Nivel Distinguido)',
            'Es Renacyt, filia por la Universidad y realiza investigaciones (Nivel II y I)',
            'Es Renacyt, filia por la Universidad y realiza investigaciones (Nivel IV y III)',
            'Es Renacyt, filia por la Universidad y realiza investigaciones (Nivel VII y V)',
            'Es Renacyt pero no filia ni realiza investigación para la Universidad.',
          ],
        },
        {
          'nombre': 'Experiencia',
          'descripcion': 'Experiencia comprobada para generar valor al puesto de trabajo, es el desarrollo de sus competencias laborales obtenidas en el cargo ó cargos similares.',
          'niveles': ['12 años 1 mes a más', '8 años 1 mes - 12 años', '3 años 1 mes - 8 años', '1 año 1 mes - 3 años', 'S/Exp. - 1 año'],
        },
        {
          'nombre': 'Excelencia de Servicio y Atención al Cliente',
          'descripcion': 'Planifica, organiza y ejecuta acciones para superar las expectativas de su cliente externo e interno.',
          'niveles': [
            'Capacidad estratégica para atender las necesidades de servicio de los clientes, otorgando en cada contacto un servicio Wow, de alta calidad.',
            'Capacidad de atención con rapidez e Identifica las necesidades del cliente.',
            'Capacidad de atender los pedidos de los clientes ofreciendo respuestas estándar a sus necesidades.',
            'Capacidad por la orientacion hacia el cliente.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Capacidad Resolutiva o Solución de Problemas',
          'descripcion': 'Capacidad de pensamiento requerido en un puesto en forma de analisis, razonamiento, evaluación, creatividad, en la aplicacion de solución de problemas.',
          'niveles': [
            'Capacidad para impulsar entornos favorables, que propicien el desarrollo institucional y ventajas competitivas.',
            'Capacidad de pensamiento estratégico, establece un fin, evalúa medios útiles y logra aplicación.',
            'Capacidad de respuesta ante los cambios del entorno laboral y solución de problemas.',
            'Capacidad de pensamiento para adaptarse a los cambios del entorno.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Emprendimiento / Intra-Emprendimiento',
          'descripcion': 'Creación de valor que permite a la comunidad universitaria proponer espacios de formación para construir conocimientos y desarrollar hábitos.',
          'niveles': [
            'Capacidad de generar, promover, fomentar y mantener nuevos proyectos innovadores y liderarlos exitosamente.',
            'Capacidad de asumir con propiedad el rol y fomenta las nuevas ideas y la creación de nuevos proyectos.',
            'Capacidad de plantear ideas, proyectos innovadores, retadores.',
            'Capacidad minima para asumir su rol.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Innovación',
          'descripcion': 'Capacidad y habilidad mental para implementar nuevos proyectos, estrategias, ideas y conceptos a esquemas existentes.',
          'niveles': [
            'Planifica, organiza e implementa ideas innovadoras que agregan alto valor a la organización.',
            'Capacidad de aportar ideas interesantes por un enfoque innovador para nuevos proyectos.',
            'Capacidad de implementar nuevos proyectos e ideas innovadoras.',
            'Capacidad de aporte minimo de implementacion de nuevos proyectos.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Competencia Digital',
          'descripcion': 'Capacidad del uso creativo, crítico y seguro de las tecnologías de la información y herramientas digitales.',
          'niveles': [
            'Planifica, organiza y dirige estrategias de tecnologia de la información para alcanzar objetivos.',
            'Capacidad de hacer el uso óptimo de la tecnología y herramientas digitales.',
            'Capacidad para el entendimiento y manejo de los sistemas informáticos.',
            'Capacidad minima en el manejo y entendimiento de programas digitales.',
            'Competencia no desarrollada para la posición.',
          ],
        },
      ],
    },
    {
      'factor': 'ESFUERZO',
      'subfactores': [
        {
          'nombre': 'Mental',
          'descripcion': 'Conjunto de tensiones inducidas en una persona por las exigencias del trabajo mental que realiza en un puesto de trabajo.',
          'niveles': [
            'Planifica, organiza e implementa acciones estratégicas que requieren la aplicacion de funciones intelectuales superiores.',
            'El trabajo exige alta concentración y el uso de conocimientos y habilidades para el logro del objetivo.',
            'El trabajo exige concentración y el uso de conocimientos y habilidades.',
            'El trabajo a ejecutar es práctico-mecanico.',
            'El trabajo sólo exige un mínimo de esfuerzo de concentración.',
          ],
        },
        {
          'nombre': 'Emocional',
          'descripcion': 'Controlar las propias emociones en situaciones de estrés, presión e incertidumbre.',
          'niveles': [
            'El puesto requiere de estrategias para el manejo y control de emociones personales y del equipo.',
            'El puesto labora en un ambiente con nivel constante y elevado de presión, estrés e incertidumbre.',
            'El puesto labora en un ambiente con nivel constante de presión, estrés e incertidumbre.',
            'El puesto opera en un entorno con bajos niveles de estrés y presión.',
            'El puesto opera en un entorno psicológico libre de presión e incertidumbre.',
          ],
        },
        {
          'nombre': 'Físico',
          'descripcion': 'Conjunto de requerimientos físicos a los que se ve sometida la persona que ocupa un puesto a lo largo de la jornada laboral.',
          'niveles': [
            'Ejerce estrategias para el uso eficiente del trabajo fisico personal y del equipo.',
            'Ejerce esfuerzo físico de manera constante.',
            'Ejerce esfuerzo fisico de manera interdiario.',
            'Ejerce esfuerzo mínimo.',
            'Sin esfuerzo.',
          ],
        },
      ],
    },
    {
      'factor': 'RESPONSABILIDAD',
      'subfactores': [
        {
          'nombre': 'Cumplimiento de Metas',
          'descripcion': 'Resultado deseado que una persona o un sistema diseña, planea y ejecuta logrando resultados eficientes.',
          'niveles': [
            'Planifica y organiza estrategias para el cumplimiento eficaz y eficiente de las metas.',
            'Demuestra resultados en las tareas asignadas, cumpliendo con cada meta propuesta.',
            'Cumple las metas designadas en el tiempo que se le ha determinado.',
            'Se esfuerza por cumplir las metas, aún fuera del tiempo establecido.',
            'No cumple con las metas que demanda su puesto de trabajo.',
          ],
        },
        {
          'nombre': 'Responsabilidades Financieras',
          'descripcion': 'Gestión y decisión sobre las magnitudes o presupuestos asignados, incluyendo pago de transacciones y libros contables.',
          'niveles': [
            'Planifica, organiza e implementa estrategias para el manejo de los recursos financeiros de la Universidad.',
            'Capacidad eficiente para el manejo de los recursos financieros de la Universidad.',
            'Capacidad del manejo de recursos financieros de la universidad.',
            'Capacidad minima para el manejo de recursos financieros.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Prestación de Servicios',
          'descripcion': 'Planifica, organiza, dirige, controla y evalua actividades relaciones con la formación integral de los estudiantes.',
          'niveles': [
            'Planifica, organiza, dirige y controla los recursos como aulas, docentes, alumnos, etc.',
            'Capacidad del manejo eficiente de los recursos como aulas, docentes, alumnos, etc.',
            'Capacidad para la atencion y utilizacion de recursos como aulas, docentes, alumnos.',
            'Capacidad minima para la atencion de las necesidades de los alumnos.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Confidencialidad',
          'descripcion': 'Capacidad de garantizar que la información del puesto y de la Universidad no sea divulgada sin los permisos pertinentes.',
          'niveles': [
            'Planifica, organiza e implementa estrategia para la proteccion de la informacion confidencial.',
            'Capacidad de gestionar la información confidencial, custodia y protege el buen uso.',
            'Capacidad de manejar y guardar información confidencial de la Universidad.',
            'Capacidad de manejar informacion de la Universidad.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Manejo de Materiales, Financieros y Tecnológicos',
          'descripcion': 'Uso eficiente de los recursos financieros, tecnologicos y materiales para el desarrollo de las funciones establecidas.',
          'niveles': [
            'Planifica, organiza e implementa estrategia para el manejo eficiente de los materiales y recursos.',
            'Capacidad del manejo eficiente de los materiales, recursos financieros y tecnologicos.',
            'Capacidad del manejo de los materiales, recursos financieros y tecnologicos.',
            'Capacidad minima del manejo de los materiales que le brinda la Universidad.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Manejo de Personas',
          'descripcion': 'Asignación de un grupo de personas para gestionar sus habilidades a fin de cumplir las funciones asignadas.',
          'niveles': [
            'Planifica, organiza e implementa estrategías para el manejo del personal y consolidacion de objetivos estratégicos.',
            'Trabaja e influye en un grupo de personas (21-40 colaboradores) para el logro de metas.',
            'Trabaja e influye en un grupo de personas (6-20 colaboradores) para el logro de metas.',
            'Trabaja e influye con un pequeño grupo de personas (1-5 colaboradores).',
            'No trabaja con personas a su cargo.',
          ],
        },
      ],
    },
    {
      'factor': 'CONDICIONES DE TRABAJO',
      'subfactores': [
        {
          'nombre': 'Físico - Riesgos Ambientales',
          'descripcion': 'Agente, factor o circunstancia que puede causar daño físico al colaborador.',
          'niveles': [
            'El puesto representa un alto riesgo fisico - ambiental para el colaborador.',
            'El puesto representa un significativo riesgo fisico - ambiental para el colaborador.',
            'El puesto representa un riesgo fisico - ambiental para el colaborador.',
            'El puesto representa un minimo riesgo fisico - ambiental para el colaborador.',
            'El puesto no representa riesgo fisico - ambiental para el colaborador.',
          ],
        },
        {
          'nombre': 'Riesgo Psicológico',
          'descripcion': 'Cuando no se puede preveer las consecuencias de los estimulos que se presentan en el puesto trabajo.',
          'niveles': [
            'El puesto representa un alto riesgo psicológico para el colaborador.',
            'El puesto representa un significativo riesgo psicológico para el colaborador.',
            'El puesto representa un riesgo psicológico para el colaborador.',
            'El puesto representa un minimo riesgo psicológico para el colaborador.',
            'El puesto no representa riesgo psicologico para el colaborador.',
          ],
        },
      ],
    },
  ];

  Color _colorFactor(String factor) {
    switch (factor) {
      case 'CALIFICACIONES Y COMPETENCIAS': return const Color(0xFF6B2D8B);
      case 'ESFUERZO':                       return const Color(0xFF2196F3);
      case 'RESPONSABILIDAD':                return const Color(0xFF7DC242);
      case 'CONDICIONES DE TRABAJO':         return const Color(0xFFFF9800);
      default:                               return Colors.grey;
    }
  }

  IconData _iconFactor(String factor) {
    switch (factor) {
      case 'CALIFICACIONES Y COMPETENCIAS': return Icons.psychology_rounded;
      case 'ESFUERZO':                       return Icons.fitness_center_rounded;
      case 'RESPONSABILIDAD':                return Icons.assignment_turned_in_rounded;
      case 'CONDICIONES DE TRABAJO':         return Icons.health_and_safety_rounded;
      default:                               return Icons.circle;
    }
  }

  Color _colorNivel(int nivel, Color base) {
    final opacities = [1.0, 0.80, 0.60, 0.40, 0.25];
    return base.withOpacity(opacities[nivel]);
  }

  void _toggle(String key) {
    setState(() {
      _expanded[key] = !(_expanded[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitulo(),
                  const SizedBox(height: 16),
                  for (int fi = 0; fi < _factores.length; fi++) ...[
                    _buildFactorBanner(_factores[fi]),
                    const SizedBox(height: 10),
                    for (int si = 0; si < (_factores[fi]['subfactores'] as List).length; si++) ...[
                      _buildSubfactorCard(
                        _factores[fi]['subfactores'][si],
                        _colorFactor(_factores[fi]['factor']),
                        '$fi-$si',
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Row(
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
                Text(
                  'Hola, ${widget.nombres.split(' ').first}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Valorización de Puestos',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(children: [
            Container(width: 50, height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05))),
            Positioned(top: 8, left: 8,
              child: Container(width: 34, height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08)))),
          ]),
        ],
      ),
    );
  }

  Widget _buildTitulo() {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
              color: const Color(0xFF6B2D8B),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        const Flexible(
          child: Text(
            'Objetivos para la Valorización de Puestos',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF3A1060)),
          ),
        ),
      ],
    );
  }

  Widget _buildFactorBanner(Map<String, dynamic> factor) {
    final color = _colorFactor(factor['factor']);
    final icon = _iconFactor(factor['factor']);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              factor['factor'],
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubfactorCard(Map<String, dynamic> sf, Color color, String key) {
    final niveles = sf['niveles'] as List;
    final isOpen = _expanded[key] ?? false;

    return GestureDetector(
      onTap: () => _toggle(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isOpen ? 0.15 : 0.07),
              blurRadius: isOpen ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header siempre visible — tappable
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isOpen ? color.withOpacity(0.12) : color.withOpacity(0.07),
                  border: Border(left: BorderSide(color: color, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sf['nombre'],
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
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

              // Contenido colapsable
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: isOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descripción
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                      child: Text(
                        sf['descripcion'],
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                            height: 1.4),
                      ),
                    ),
                    // Separador con label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Text('Niveles',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: color)),
                          const SizedBox(width: 8),
                          Expanded(child: Divider(color: color.withOpacity(0.2))),
                          const SizedBox(width: 8),
                          Text('Grado',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: color)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Filas de niveles
                    for (int i = 0; i < niveles.length; i++)
                      _buildNivelRow(
                          niveles[i], 5 - i, color, i == niveles.length - 1),
                    const SizedBox(height: 10),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNivelRow(String texto, int grado, Color color, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: (5 - grado) % 2 == 0
            ? const Color(0xFFFAF8FC)
            : Colors.white,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de grado
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: _colorNivel(5 - grado, color),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$grado',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Texto del nivel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                texto,
                style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF333333),
                    height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}