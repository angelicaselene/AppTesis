import 'package:flutter/material.dart';

class ValorizacionScreen extends StatelessWidget {
  final String nombres;
  const ValorizacionScreen({super.key, required this.nombres});

  static const List<Map<String, dynamic>> _factores = [
    {
      'factor': 'CALIFICACIONES Y COMPETENCIAS',
      'subfactores': [
        {
          'nombre': 'Formación Profesional',
          'descripcion':
              'Valora los conocimientos académicos necesarios para ejercer con efectividad las responsabilidades de un puesto y alcanzar los resultados previstos.',
          'niveles': [
            'Doctorado - PHD',
            'Maestría (as)',
            'Titulado',
            'Bachiller Universitario',
            'Técnico o menos',
          ],
        },
        {
          'nombre': 'Investigación',
          'descripcion':
              'Valora los aportes de investigacion que son necesarios para ejercer con efectividad las responsabilidades de un puesto y alcanzar los resultados previstos por la Universidad.',
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
          'descripcion':
              'Experiencia comprobada para generar valor al puesto de trabajo, es el desarrollo de sus competencias laborales obtenidas en el cargo ó cargos similares que capacitan a una persona.',
          'niveles': [
            '12 años 1 mes a más',
            '8 años 1 mes - 12 años',
            '3 años 1 mes - 8 años',
            '1 año 1 mes - 3 años',
            'S/Exp. - 1 año',
          ],
        },
        {
          'nombre': 'Excelencia de Servicio y Atención al Cliente',
          'descripcion':
              'Planifica, organiza y ejecuta acciones para superar las expectativas de su cliente externo e interno, satisface al cliente y adopta estrategias y tácticas para brindarle el mejor servicio/producto, anticipando sus necesidades.',
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
          'descripcion':
              'Capacidad de pensamiento requerido en un puesto en forma de analisis, razonamiento, evaluación, creatividad, en la aplicacion de solución de problemas que requiere el puesto de trabajo.',
          'niveles': [
            'Capacidad para impulsar entornos favorables, que propicien el desarrollo institucional, condiciones de mercado, crecimiento empresarial, desarrollando de manera continua ventajas competitivas.',
            'Capacidad de pensamiento estratégico, establece un fin, evalúa medios útiles y logra aplicación, obteniendo el máximo beneficio.',
            'Capacidad de respuesta ante los cambios del entorno laboral y solución de problemas.',
            'Capacidad de pensamiento para adaptarse a los cambios del entorno, detectando nuevas oportunidades que aporten al desarrollo de la Universidad.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Emprendimiento / Intra-Emprendimiento',
          'descripcion':
              'Creación de valor que permite a la comunidad universitaria proponer espacios y escenarios de formación para construir conocimientos y desarrollar hábitos, actitudes y valores necesarios para generar acciones orientadas al mejoramiento personal y a la transformación del entorno y de la sociedad.',
          'niveles': [
            'Capacidad de generar, promover, fomentar y mantener nuevos proyectos innovadores dentro de la universidad y es capaz de liderarlos exitosamente.',
            'Capacidad de asumir con propiedad el rol y fomenta las nuevas ideas y la creación de nuevos proyectos.',
            'Capacidad de plantear ideas, proyectos innovadores, retadores.',
            'Capacidad minima para asumir su rol.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Innovación',
          'descripcion':
              'Capacidad y habilidad mental para implementar nuevos proyectos, estrategias, ideas y conceptos a esquemas existentes, transformándo el entorno laboral.',
          'niveles': [
            'Planifica, organiza e implementa ideas innovadoras que se concretan en realidades tangibles que agregan alto valor a la organización.',
            'Capacidad de aportar ideas interesantes por un enfoque innovador, que son útiles para nuevos proyectos.',
            'Capacidad de implementar nuevos proyectos e ideas innovadoras.',
            'Capacidad de aporte minimo de implementacion de nuevos proyectos, ideas innovadoras.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Competencia Digital',
          'descripcion':
              'Capacidad del uso creativo, crítico y seguro de las tecnologías de la información, herramientas digitales y la comunicación para alcanzar los objetivos relacionados con el trabajo.',
          'niveles': [
            'Planifica, organiza y dirige estrategias de tecnologia de la información para alcanzar objetivos de conocimiento tácito y explícito.',
            'Capacidad de hacer el uso óptimo de la tecnología y herramientas digitales, que implica el uso crítico y seguro de las herramientas en el puesto de trabajo.',
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
          'descripcion':
              'Es el conjunto de tensiones inducidas en una persona por las exigencias del trabajo mental que realiza en un puesto de trabajo en relación al procesamiento de información del entorno a partir de los conocimientos previos.',
          'niveles': [
            'Planifica, organiza e implementa acciones estratégicas que requieren la aplicacion de las funciones intelectuales superiores.',
            'El trabajo exige alta concentración y el uso de conocimientos y habilidades para el logro del objetivo del puesto.',
            'El trabajo exige concentración y el uso de conocimientos y habilidades para el logro del objetivo del puesto.',
            'El trabajo a ejecutar es práctico-mecanico.',
            'El trabajo sólo exige un mínimo de esfuerzo de concentración y habilidades.',
          ],
        },
        {
          'nombre': 'Emocional',
          'descripcion':
              'Controlar las propias emociones en situaciones de estrés, presión e incertidumbre.',
          'niveles': [
            'El puesto requiere de estrategias para el manejo y control de emociones personales y del equipo de trabajo.',
            'El puesto labora en un ambiente donde existe un nivel constante y elevado de presión, estrés e incertidumbre.',
            'El puesto labora en un ambiente donde existe un nivel constante de presión, estrés e incertidumbre.',
            'El puesto opera en un entorno que en general tiene bajos niveles de estrés y presión.',
            'El puesto opera en un entorno psicológico libre de presión e incertidumbre.',
          ],
        },
        {
          'nombre': 'Físico',
          'descripcion':
              'Es la carga física de trabajo, conjunto de requerimientos físicos a los que se ve sometida la persona que ocupa un puesto determinado a lo largo de la jornada laboral.',
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
          'descripcion':
              'Es el resultado deseado que una persona o un sistema diseña, planea y ejecuta logrando resultados eficientes en cada meta de su posición.',
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
          'descripcion':
              'Gestión y decisión sobre las magnitudes o presupuestos asignados, tambien incluye el pago de transacciones grandes o el tener libros contables.',
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
          'descripcion':
              'Planifica, organiza, dirige, controla y evalua actividades relaciones con la formación integral de los estudiantes universitarios.',
          'niveles': [
            'Planifica, organiza, dirige y controla los recursos como aulas, docentes, alumnos, etc.',
            'Capacidad del manejo eficiente de los recursos como aulas, docentes, alumnos, etc.',
            'Capacidad para la atencion y utilizacion de recursos como aulas, docentes, alumnos, etc.',
            'Capacidad minima para la atencion y utilizacion de recursos de las necesidades de los alumnos.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Confidencialidad',
          'descripcion':
              'Es la capacidad de garantizar que la información de su puesto de trabajo y de la Universidad, no sea protegida y divulgada en el entorno sin los permisos y autorizaciones pertinentes.',
          'niveles': [
            'Planifica, organiza e implementa estrategia para la proteccion de la informacion confidencial de la Universidad.',
            'Capacidad de gestionar la información confidencial, custodia y protege el buen uso de la misma.',
            'Capacidad de manejar y guardar información confidencial de la Universidad.',
            'Capacidad de manejar informacion de la Universidad.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Manejo de Materiales, Financieros y Tecnológicos',
          'descripcion':
              'Es el uso eficiente de los recursos financieros, tecnologicos y materiales que utiliza el puesto para el desarrollo de las funciones establecidas.',
          'niveles': [
            'Planifica, organiza e implementa estrategia para el manejo eficiente de los materiales, recursos financieros y tecnologicos que entrega la Universidad.',
            'Capacidad del manejo eficiente de los materiales, recursos financieros y tecnologicos que entrega la Universidad.',
            'Capacidad del manejo de los materiales, recursos financieros y tecnologicos que entrega la Universidad.',
            'Capacidad minima del manejo de los materiales que le brinda la Universidad.',
            'Competencia no desarrollada para la posición.',
          ],
        },
        {
          'nombre': 'Manejo de Personas',
          'descripcion':
              'Es la asignación de un grupo de personas, para gestionar sus habilidades a fin de cumplir las funciones asignadas.',
          'niveles': [
            'Planifica, organiza e implementa estrategías para el manejo del personal, alumnos y otros, para la consolidacion de los objetivos estratégicos de la Universidad.',
            'Trabaja e influye en un grupo de personas (21-40 colaboradores), para el logro de las metas y objetivos en el area desarrollada.',
            'Trabaja e influye en un grupo de personas (6-20 colaboradores), para el logro de las metas y objetivos en el area desarrollada.',
            'Trabaja e influye con un pequeño grupo de personas (1-5 colaboradores), para el logro de las metas y objetivos en el area desarrollada.',
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
          'descripcion':
              'Es un agente, factor o circunstancia que puede causar daño físico al colaborador.',
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
          'descripcion':
              'Es cuando no se puede preveer las consecuencias de los estimulos que se presentan en el puesto trabajo (Objeto, situación, persona).',
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
      case 'CALIFICACIONES Y COMPETENCIAS':
        return const Color(0xFF6B2D8B);
      case 'ESFUERZO':
        return const Color(0xFF2196F3);
      case 'RESPONSABILIDAD':
        return const Color(0xFF7DC242);
      case 'CONDICIONES DE TRABAJO':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'OBJETIVOS PARA LA VALORIZACIÓN DE PUESTOS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  for (final factor in _factores) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _colorFactor(factor['factor']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: _colorFactor(factor['factor']),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        factor['factor'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _colorFactor(factor['factor']),
                        ),
                      ),
                    ),
                    for (final sf in factor['subfactores'] as List) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: _colorFactor(factor['factor']),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _colorFactor(factor['factor']),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(9),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                sf['nombre'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                sf['descripcion'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Descripción',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _colorFactor(factor['factor']),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Niveles',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _colorFactor(factor['factor']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            for (
                              int i = 0;
                              i < (sf['niveles'] as List).length;
                              i++
                            )
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        sf['niveles'][i],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _colorFactor(factor['factor']),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${5 - i}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
