import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'homescreen.dart';
import 'dart:math';
import 'package:vocacional_app/database/db_helper.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? initialProgress; // 👈 NUEVO: para continuar test
  final bool startNew; // 👈 NUEVO: para empezar nuevo

  const QuizScreen({
    super.key,
    required this.userData,
    this.initialProgress, // 👈 Opcional
    this.startNew = false, // 👈 Opcional, por defecto false
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // Animaciones modernas
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Lista de preguntas en el orden específico
  final List<String> riasecQuestions = [
    // 1. Realista (R)
    'Me gusta trabajar con automóviles.',
    // 2. Investigador (I)
    'Disfruto resolviendo rompecabezas.',
    // 3. Artístico (A)
    'Soy bueno trabajando de manera independiente.',
    // 4. Social (S)
    'Me agrada colaborar y trabajar en equipo.',
    // 5. Emprendedor (E)
    'Soy una persona ambiciosa y me gusta establecer metas.',
    // 6. Convencional (C)
    'Me gusta organizar objetos o espacios, como archivos o escritorios.',
    // 7. Realista (R)
    'Disfruto construir o armar cosas.',
    // 8. Artístico (A)
    'Me interesa leer sobre arte y música.',
    // 9. Convencional (C)
    'Prefiero seguir instrucciones claras y definidas.',
    // 10. Emprendedor (E)
    'Me gusta influir o persuadir a otras personas.',
    // 11. Investigador (I)
    'Disfruto realizando experimentos.',
    // 12. Social (S)
    'Me agrada enseñar o capacitar a otras personas.',
    // 13. Social (S)
    'Me gusta ayudar a los demás a resolver sus problemas.',
    // 14. Realista (R)
    'Disfruto cuidar y atender animales.',
    // 15. Convencional (C)
    'No me molestaría trabajar ocho horas diarias en una oficina.',
    // 16. Emprendedor (E)
    'Me gusta vender productos o servicios.',
    // 17. Artístico (A)
    'Disfruto escribir de manera creativa.',
    // 18. Investigador (I)
    'Me apasiona la ciencia.',
    // 19. Emprendedor (E)
    'Asumo con rapidez nuevas responsabilidades.',
    // 20. Social (S)
    'Me interesa curar o atender a las personas.',
    // 21. Investigador (I)
    'Disfruto descubrir cómo funcionan las cosas.',
    // 22. Realista (R)
    'Me agrada ensamblar o unir piezas para formar algo.',
    // 23. Artístico (A)
    'Me considero una persona creativa.',
    // 24. Convencional (C)
    'Presto atención a los detalles en mi trabajo.',
    // 25. Convencional (C)
    'Me gusta archivar documentos o escribir a máquina.',
    // 26. Investigador (I)
    'Disfruto analizar problemas o situaciones.',
    // 27. Artístico (A)
    'Me gusta tocar instrumentos o cantar.',
    // 28. Social (S)
    'Me interesa aprender sobre otras culturas.',
    // 29. Emprendedor (E)
    'Me gustaría iniciar y dirigir mi propio negocio.',
    // 30. Realista (R)
    'Disfruto cocinar y preparar alimentos.',
    // 31. Artístico (A)
    'Me gusta actuar o participar en obras de teatro.',
    // 32. Realista (R)
    'Me considero una persona práctica y orientada a la acción.',
    // 33. Investigador (I)
    'Disfruto trabajar con números, gráficos o datos.',
    // 34. Social (S)
    'Me gusta debatir o discutir temas de interés.',
    // 35. Convencional (C)
    'Soy bueno registrando y manteniendo ordenado mi trabajo.',
    // 36. Emprendedor (E)
    'Me gusta liderar y dirigir a otras personas.',
    // 37. Realista (R)
    'Disfruto trabajar al aire libre.',
    // 38. Convencional (C)
    'Me gustaría tener un empleo en oficina.',
    // 39. Investigador (I)
    'Soy bueno en matemáticas.',
    // 40. Social (S)
    'Me agrada ayudar y apoyar a otras personas.',
    // 41. Artístico (A)
    'Me gusta dibujar o realizar ilustraciones.',
    // 42. Emprendedor (E)
    'Disfruto hablar en público o dar discursos.',
  ];

  final Map<int, String> questionCategories = {
    0: 'Realista (R)',
    1: 'Investigador (I)',
    2: 'Artístico (A)',
    3: 'Social (S)',
    4: 'Emprendedor (E)',
    5: 'Convencional (C)',
    6: 'Realista (R)',
    7: 'Artístico (A)',
    8: 'Convencional (C)',
    9: 'Emprendedor (E)',
    10: 'Investigador (I)',
    11: 'Social (S)',
    12: 'Social (S)',
    13: 'Realista (R)',
    14: 'Convencional (C)',
    15: 'Emprendedor (E)',
    16: 'Artístico (A)',
    17: 'Investigador (I)',
    18: 'Emprendedor (E)',
    19: 'Social (S)',
    20: 'Investigador (I)',
    21: 'Realista (R)',
    22: 'Artístico (A)',
    23: 'Convencional (C)',
    24: 'Convencional (C)',
    25: 'Investigador (I)',
    26: 'Artístico (A)',
    27: 'Social (S)',
    28: 'Emprendedor (E)',
    29: 'Realista (R)',
    30: 'Artístico (A)',
    31: 'Realista (R)',
    32: 'Investigador (I)',
    33: 'Social (S)',
    34: 'Convencional (C)',
    35: 'Emprendedor (E)',
    36: 'Realista (R)',
    37: 'Convencional (C)',
    38: 'Investigador (I)',
    39: 'Social (S)',
    40: 'Artístico (A)',
    41: 'Emprendedor (E)',
  };

  final Map<String, List<String>> careerSuggestions = {
    'Realista (R)': [
      'Agricultura y Agronomía',
      'Asistente de Salud',
      'Tecnología en Computación',
      'Ingeniería en Construcción',
      'Mecánica y Maquinaria',
      'Ingeniería General',
      'Gastronomía y Hospitalidad',
      'Tecnologías de la Información',
      'Ciencias de la Salud',
      'Tecnología Industrial',
      'Innovación Alimentaria'
    ],
    'Social (S)': [
      'Psicología y Asesoramiento',
      'Enfermería Profesional',
      'Fisioterapia y Rehabilitación',
      'Turismo y Gestión de Viajes',
      'Publicidad y Marketing',
      'Relaciones Públicas',
      'Pedagogía y Educación',
      'Servicios Humanos',
      'Educación Especial',
      'Derecho y Gobierno',
      'Hotelería y Turismo'
    ],
    'Investigador (I)': [
      'Biología Marina',
      'Ingenierías Especializadas',
      'Química y Bioquímica',
      'Zoología y Veterinaria',
      'Medicina y Cirugía',
      'Economía y Consumo',
      'Psicología Clínica',
      'Administración de Negocios',
      'Investigación en Salud',
      'Ingeniería Tecnológica',
      'Ciencias Políticas'
    ],
    'Emprendedor (E)': [
      'Merchandising de Moda',
      'Bienes Raíces',
      'Marketing y Ventas',
      'Derecho Corporativo',
      'Ciencia Política',
      'Comercio Internacional',
      'Banca y Finanzas',
      'Medios Creativos',
      'Administración Empresarial',
      'Derecho Público'
    ],
    'Artístico (A)': [
      'Ciencias de la Comunicación',
      'Cosmetología Avanzada',
      'Bellas Artes',
      'Fotografía Profesional',
      'Radio y Televisión',
      'Diseño de Interiores',
      'Arquitectura',
      'Medios Creativos',
      'Derecho Creativo'
    ],
    'Convencional (C)': [
      'Contabilidad y Finanzas',
      'Taquigrafía Judicial',
      'Seguros y Riesgos',
      'Administración General',
      'Historia Médica',
      'Banca y Finanzas',
      'Procesamiento de Datos',
      'Negocios Estructurados',
      'Servicios de Salud',
      'Ingeniería de Procesos'
    ],
  };

  final Map<String, String> careerDescriptions = {
    'Agricultura y Agronomía': 'Profesión dedicada al cultivo de la tierra, producción de alimentos y gestión de recursos naturales. Ideal para personas que disfrutan trabajar al aire libre, manejar maquinaria agrícola y contribuir a la seguridad alimentaria mediante técnicas sostenibles y innovadoras.',
    'Asistente de Salud': 'Carrera enfocada en proporcionar apoyo esencial en entornos médicos, asistir a profesionales de la salud y garantizar el bienestar de los pacientes. Perfecta para quienes valoran el servicio directo y tienen habilidades prácticas en cuidado humano.',
    'Tecnología en Computación': 'Profesión técnica especializada en hardware, redes y sistemas informáticos. Diseñada para mentes prácticas que disfrutan resolver problemas tecnológicos concretos y trabajar con equipos físicos.',
    'Ingeniería en Construcción': 'Carrera práctica centrada en la planificación, diseño y ejecución de proyectos de infraestructura. Ideal para quienes disfrutan trabajar en obra, manejar equipos pesados y ver resultados tangibles.',
    'Mecánica y Maquinaria': 'Profesión técnica especializada en el mantenimiento, reparación y optimización de maquinaria industrial y vehículos. Perfecta para manos hábiles y mentes analíticas prácticas.',
    'Ingeniería General': 'Formación integral en principios de ingeniería aplicada a múltiples disciplinas. Diseñada para resolver problemas técnicos concretos mediante metodologías científicas y prácticas.',
    'Gastronomía y Hospitalidad': 'Carrera combinando arte culinario con gestión de servicios. Ideal para personas prácticas que disfrutan ambientes dinámicos y crear experiencias memorables mediante la comida.',
    'Tecnologías de la Información': 'Profesión práctica enfocada en implementar y mantener soluciones tecnológicas. Perfecta para quienes disfrutan trabajar con sistemas concretos y resultados medibles.',
    'Ciencias de la Salud': 'Campo diverso aplicando conocimientos científicos al cuidado humano. Combinando investigación con práctica clínica para mejorar la calidad de vida de las personas.',
    'Tecnología Industrial': 'Especialización en optimización de procesos productivos y manejo de tecnología avanzada. Ideal para mentes prácticas orientadas a la eficiencia y mejora continua.',
    'Innovación Alimentaria': 'Carrera fusionando tecnología agrícola con ciencia de alimentos. Enfocada en desarrollar productos alimenticios sostenibles y nutritivos para el futuro.',
    'Psicología y Asesoramiento': 'Profesión dedicada a comprender y mejorar la salud mental mediante apoyo terapéutico. Ideal para personas empáticas que disfrutan ayudar a otros en su crecimiento personal.',
    'Enfermería Profesional': 'Carrera de servicio centrada en el cuidado integral del paciente. Combinando conocimientos médicos con compasión humana en entornos de salud diversos.',
    'Fisioterapia y Rehabilitación': 'Especialización en recuperación física y mejora de la movilidad. Perfecta para quienes disfrutan ver el progreso tangible en la calidad de vida de las personas.',
    'Turismo y Gestión de Viajes': 'Profesión dinámica enfocada en crear experiencias turísticas memorables. Ideal para personas sociables que disfrutan mostrar culturas y destinos.',
    'Publicidad y Marketing': 'Carrera creativa dedicada a conectar marcas con audiencias. Combinando psicología del consumidor con estrategias de comunicación persuasiva.',
    'Relaciones Públicas': 'Profesión estratégica especializada en gestión de imagen y comunicación organizacional. Perfecta para comunicadores natos con habilidades diplomáticas.',
    'Pedagogía y Educación': 'Vocación dedicada a la formación de nuevas generaciones. Enfocada en desarrollar métodos de enseñanza que inspiren el amor por el aprendizaje.',
    'Servicios Humanos': 'Campo diverso dedicado al bienestar comunitario mediante programas de apoyo social. Ideal para quienes buscan impacto social directo.',
    'Educación Especial': 'Especialización en enseñanza adaptada a necesidades educativas particulares. Requiere paciencia, creatividad y compromiso con la inclusión.',
    'Derecho y Gobierno': 'Carrera de servicio pública enfocada en justicia y administración estatal. Perfecta para quienes disfrutan el debate y la construcción de sociedad.',
    'Hotelería y Turismo': 'Profesión de servicio especializada en experiencias hoteleras de calidad. Combinando gestión operativa con atención al cliente excepcional.',
    'Biología Marina': 'Ciencia dedicada al estudio de ecosistemas acuáticos y conservación marina. Ideal para mentes curiosas fascinadas por la vida oceánica y su preservación.',
    'Ingenierías Especializadas': 'Campos técnicos avanzados requiriendo profunda investigación y desarrollo. Perfectos para solucionadores de problemas complejos mediante ciencia aplicada.',
    'Química y Bioquímica': 'Ciencia fundamental estudiando la composición de la materia y reacciones biológicas. Base para innovación en medicina, materiales y tecnología.',
    'Zoología y Veterinaria': 'Carrera científica dedicada al estudio animal y su cuidado médico. Combinando investigación biológica con práctica clínica veterinaria.',
    'Medicina y Cirugía': 'Profesión de investigación clínica aplicada al diagnóstico y tratamiento de enfermedades. Requiere curiosidad científica continua y compromiso humano.',
    'Economía y Consumo': 'Ciencia social analizando patrones económicos y comportamiento del consumidor. Fundamental para entender y predecir tendencias de mercado.',
    'Psicología Clínica': 'Investigación científica aplicada al entendimiento de la conducta humana y salud mental. Combinando metodología experimental con práctica terapéutica.',
    'Administración de Negocios': 'Campo de investigación aplicada a optimización organizacional y estrategias empresariales. Basado en análisis de datos y tendencias de mercado.',
    'Investigación en Salud': 'Carrera científica dedicada al avance médico mediante estudios clínicos y experimentación. Motor de innovación en tratamientos y prevención.',
    'Ingeniería Tecnológica': 'Investigación aplicada al desarrollo de nuevas tecnologías y sistemas avanzados. Fusionando principios científicos con innovación práctica.',
    'Ciencias Políticas': 'Estudio sistemático de sistemas de gobierno, poder político y relaciones internacionales. Base para políticas públicas informadas y democracia.',
    'Merchandising de Moda': 'Carrera emprendedora fusionando creatividad con estrategia comercial en retail. Ideal para trendsetters con visión de negocio en industria fashion.',
    'Bienes Raíces': 'Profesión de negocios especializada en transacciones inmobiliarias y desarrollo de propiedades. Perfecta para negociadores con visión de inversión.',
    'Marketing y Ventas': 'Campo dinámico enfocado en estrategias comerciales y generación de ingresos. Para líderes persuasivos con mentalidad de crecimiento empresarial.',
    'Derecho Corporativo': 'Especialización legal en negocios, fusiones y asesoría empresarial. Combinando expertise jurídico con visión de negocio estratégico.',
    'Ciencia Política': 'Carrera de liderazgo analizando poder político y tomando decisiones gubernamentales. Base para emprendedores en sector público y políticas.',
    'Comercio Internacional': 'Negocios globales especializados en importación/exportación y mercados mundiales. Para visionarios con mentalidad global y estratégica.',
    'Banca y Finanzas': 'Profesión de alto nivel en gestión de inversiones y servicios financieros. Ideal para tomadores de riesgo con visión económica a largo plazo.',
    'Medios Creativos': 'Industria emprendedora fusionando arte con modelos de negocio innovadores. Para creadores con mentalidad empresarial y comercial.',
    'Administración Empresarial': 'Liderazgo organizacional enfocado en crecimiento estratégico y eficiencia operativa. Formando directivos con visión global de negocios.',
    'Derecho Público': 'Carrera de influencia en legislación, políticas públicas y defensa legal. Para líderes que buscan impacto social mediante marco legal.',
    'Ciencias de la Comunicación': 'Arte de transmitir mensajes creativos mediante diversos medios y plataformas. Ideal para storytellers natos con visión innovadora.',
    'Cosmetología Avanzada': 'Arte científico de la belleza y cuidado estético personalizado. Combinando creatividad visual con conocimientos dermatológicos.',
    'Bellas Artes': 'Expresión creativa pura mediante pintura, escultura y artes visuales. Para almas artísticas buscando comunicación no verbal profunda.',
    'Fotografía Profesional': 'Arte de capturar momentos y contar historias mediante imágenes. Fusionando técnica precisa con sensibilidad artística única.',
    'Radio y Televisión': 'Arte de entretener e informar mediante producción audiovisual. Para comunicadores creativos con carisma y visión mediática.',
    'Diseño de Interiores': 'Arte de crear espacios funcionales que inspiren emociones y bienestar. Combinando estética con psicología ambiental.',
    'Arquitectura': 'Arte científico de diseñar espacios habitables que fusionan forma y función. Para mentes creativas con visión estructural y social.',
    'Medios Creativos': 'Industria artística innovando en contenido digital, multimedia y entretenimiento. Para pioneros de nuevas formas de expresión.',
    'Derecho Creativo': 'Especialización única fusionando marco legal con industrias creativas y propiedad intelectual. Para mentes artísticas con visión jurídica.',
    'Contabilidad y Finanzas': 'Profesión metódica especializada en precisión numérica y gestión financiera. Ideal para mentes organizadas que disfrutan el orden y exactitud.',
    'Taquigrafía Judicial': 'Especialización técnica en transcripción legal precisa y documentación judicial. Requiere máxima atención al detalle y metodología.',
    'Seguros y Riesgos': 'Carrera estructurada en evaluación metódica de riesgos y protección financiera. Perfecta para analistas cuidadosos y preventivos.',
    'Administración General': 'Profesión organizada enfocada en eficiencia operativa y procesos estandarizados. Para mentes sistemáticas que valoran el orden.',
    'Historia Médica': 'Especialización meticulosa en gestión de registros clínicos y documentación sanitaria. Requiere precisión extrema y organización.',
    'Banca y Finanzas': 'Carrera estructurada en servicios financieros sistemáticos y operaciones bancarias. Ideal para profesionales metódicos y confiables.',
    'Procesamiento de Datos': 'Profesión técnica especializada en gestión sistemática de información digital. Perfecta para amantes del orden y procedimientos.',
    'Negocios Estructurados': 'Administración empresarial basada en procesos estandarizados y gestión metodológica. Para mentes organizadas en entornos corporativos.',
    'Servicios de Salud': 'Gestión metódica de instituciones médicas y procesos sanitarios estandarizados. Combinando cuidado con eficiencia administrativa.',
    'Ingeniería de Procesos': 'Optimización sistemática de operaciones industriales mediante metodologías estandarizadas. Para ingenieros amantes del orden y eficiencia.',
  };

  Map<String, int> scores = {
    'Realista (R)': 0,
    'Investigador (I)': 0,
    'Artístico (A)': 0,
    'Social (S)': 0,
    'Emprendedor (E)': 0,
    'Convencional (C)': 0,
  };

  // Lista para guardar las respuestas y poder retroceder
  List<bool?> answersHistory = [];

  int currentQuestionIndex = 0;
  bool testCompleted = false;
  bool _showFeedback = false;
  bool? _lastAnswer;
  late String _currentCategory;
  bool _isLoading = true;
  bool _autoSaveEnabled = true;

  // Colores modernos para 2026
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFFA8E6CF);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color glassWhite = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // 👇 NUEVA LÓGICA: Si hay initialProgress, cargar ese progreso
    if (widget.initialProgress != null) {
      _loadFromProgress(widget.initialProgress!);
    } else if (!widget.startNew) {
      // Solo cargar progreso guardado si no es nuevo test
      loadProgress();
    } else {
      // Es un test nuevo, no cargar nada
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _currentCategory = getCurrentCategory();
  }

  // 👇 NUEVO MÉTODO: Cargar progreso desde el parámetro initialProgress
  void _loadFromProgress(Map<String, dynamic> progress) {
    setState(() {
      currentQuestionIndex = progress['currentQuestionIndex'] ?? 0;

      // Cargar scores
      if (progress['scores'] != null) {
        scores = Map<String, int>.from(progress['scores']);
      }

      // Cargar historial de respuestas si existe
      if (progress['answersHistory'] != null) {
        answersHistory = (progress['answersHistory'] as List)
            .map((e) => e == 'true' ? true : (e == 'false' ? false : null))
            .toList();
      }

      _currentCategory = getCurrentCategory();
      _isLoading = false;
    });

    // Animar
    _slideController.forward();
  }

  // Método para guardar el progreso
  Future<void> saveProgress({bool showMessage = true}) async {
    final dbHelper = DBHelper();

    final progressData = {
      'userId': widget.userData['id'],
      'testType': 'RIASEC',
      'currentQuestionIndex': currentQuestionIndex,
      'scores': scores,
      'answersHistory': answersHistory.map((e) => e?.toString()).toList(),
      'lastUpdate': DateTime.now().toIso8601String(),
    };

    try {
      await dbHelper.saveTestProgress(progressData);
      if (showMessage) {
        _showSaveSuccess();
      }
      print('Progreso guardado: Pregunta $currentQuestionIndex');
    } catch (e) {
      print('Error al guardar progreso: $e');
      if (showMessage) {
        _showSaveError();
      }
    }
  }

  void _showSaveSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Progreso guardado correctamente!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Error al guardar el progreso'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método para cargar el progreso guardado
  Future<void> loadProgress() async {
    // Si es un test nuevo, no cargar progreso
    if (widget.startNew) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final dbHelper = DBHelper();

    try {
      final progress = await dbHelper.getTestProgress(
        widget.userData['id'],
        'RIASEC'
      );

      if (progress != null && progress.isNotEmpty) {
        setState(() {
          currentQuestionIndex = progress['currentQuestionIndex'] ?? 0;
          scores = Map<String, int>.from(progress['scores'] ?? {
            'Realista (R)': 0,
            'Investigador (I)': 0,
            'Artístico (A)': 0,
            'Social (S)': 0,
            'Emprendedor (E)': 0,
            'Convencional (C)': 0,
          });

          // Cargar historial de respuestas
          if (progress['answersHistory'] != null) {
            answersHistory = (progress['answersHistory'] as List)
                .map((e) => e == 'true' ? true : (e == 'false' ? false : null))
                .toList();
          }

          _currentCategory = getCurrentCategory();

          // Si ya completó el test, mostrar resultados
          if (currentQuestionIndex >= 42) {
            testCompleted = true;
          }
        });
        print('Progreso cargado: Pregunta $currentQuestionIndex');
      }
    } catch (e) {
      print('Error al cargar progreso: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para limpiar el progreso (cuando se complete el test)
  Future<void> clearProgress() async {
    final dbHelper = DBHelper();

    try {
      await dbHelper.deleteTestProgress(widget.userData['id'], 'RIASEC');
      print('Progreso eliminado');
    } catch (e) {
      print('Error al eliminar progreso: $e');
    }
  }

  // Método para reiniciar el test
  Future<void> restartTest() async {
    setState(() {
      currentQuestionIndex = 0;
      testCompleted = false;
      scores = {
        'Realista (R)': 0,
        'Investigador (I)': 0,
        'Artístico (A)': 0,
        'Social (S)': 0,
        'Emprendedor (E)': 0,
        'Convencional (C)': 0,
      };
      answersHistory = [];
      _currentCategory = getCurrentCategory();
    });
    await clearProgress();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Test reiniciado correctamente'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // NUEVO: Método para retroceder a la pregunta anterior
  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      // Obtener la respuesta anterior
      bool? previousAnswer = answersHistory.length > currentQuestionIndex - 1
          ? answersHistory[currentQuestionIndex - 1]
          : null;

      // Si había una respuesta, restar del score
      if (previousAnswer != null) {
        final previousCategory = questionCategories[currentQuestionIndex - 1] ?? 'Realista (R)';
        if (previousAnswer) {
          scores[previousCategory] = scores[previousCategory]! - 1;
        }
      }

      setState(() {
        currentQuestionIndex--;
        _currentCategory = getCurrentCategory();
        // Remover la respuesta actual del historial si existe
        if (answersHistory.length > currentQuestionIndex) {
          answersHistory = answersHistory.sublist(0, currentQuestionIndex);
        }
        _showFeedback = false;
      });

      // Animar el cambio
      _slideController.reset();
      _slideController.forward();

      // Guardar progreso después de retroceder
      if (_autoSaveEnabled) {
        saveProgress(showMessage: false);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String getCurrentCategory() {
    return questionCategories[currentQuestionIndex] ?? 'Realista (R)';
  }

  void answerQuestion(bool answer) async {
    final category = getCurrentCategory();

    setState(() {
      _lastAnswer = answer;
      _showFeedback = true;

      if (answer) {
        scores[category] = scores[category]! + 1;
      }

      // Guardar respuesta en el historial
      if (answersHistory.length <= currentQuestionIndex) {
        answersHistory.add(answer);
      } else {
        answersHistory[currentQuestionIndex] = answer;
      }
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _showFeedback = false;

        if (currentQuestionIndex < 41) {
          currentQuestionIndex++;
          _currentCategory = getCurrentCategory();

          // Animar la transición
          _slideController.reset();
          _slideController.forward();

          // Guardado automático después de cada respuesta
          if (_autoSaveEnabled) {
            saveProgress(showMessage: false);
          }
        } else {
          testCompleted = true;
          // Limpiar progreso cuando se complete el test
          clearProgress();
        }
      });
    }
  }

  void toggleAutoSave() {
    setState(() {
      _autoSaveEnabled = !_autoSaveEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_autoSaveEnabled
          ? 'Guardado automático ACTIVADO'
          : 'Guardado automático DESACTIVADO'),
        backgroundColor: _autoSaveEnabled ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> getTestResults() {
    String dominantCategory = '';
    int highestScore = -1;

    scores.forEach((category, score) {
      if (score > highestScore) {
        highestScore = score;
        dominantCategory = category;
      }
    });

    final suggestedCareers = careerSuggestions[dominantCategory] ?? [];
    final careersWithDescriptions = suggestedCareers.map((career) => {
      'name': career,
      'description': careerDescriptions[career] ?? 'Descripción no disponible'
    }).toList();

    return {
      'dominantCategory': dominantCategory,
      'scores': scores,
      'careers': careersWithDescriptions,
    };
  }

  void showResults(BuildContext context) async {
    final results = getTestResults();
    final dbHelper = DBHelper();

    final resultData = {
      'userId': widget.userData['id'],
      'testType': 'RIASEC',
      'resultType': results['dominantCategory'],
      'details': {
        'scores': results['scores'],
        'dominantCategory': results['dominantCategory'],
        'careers': results['careers'],
        'date': DateTime.now().toIso8601String(),
      },
    };

    try {
      await dbHelper.saveTestResult(resultData);
    } catch (e) {
      print('Error al guardar resultados: $e');
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.purple.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del diálogo moderno
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Resultados del Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Perfil dominante con glassmorphism
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stars,
                                color: primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu perfil dominante',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    results['dominantCategory'],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gráfico de barras moderno
                      const Text(
                        'Puntajes por Categoría',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBarChart(results['scores']),
                      const SizedBox(height: 16),

                      // Leyenda moderna
                      const Text(
                        'Leyenda:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildLegendItem(Colors.blue, 'Realista'),
                          _buildLegendItem(Colors.green, 'Investigador'),
                          _buildLegendItem(Colors.purple, 'Artístico'),
                          _buildLegendItem(Colors.red, 'Social'),
                          _buildLegendItem(Colors.orange, 'Emprendedor'),
                          _buildLegendItem(Colors.teal, 'Convencional'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Carreras sugeridas - con diseño moderno
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school,
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Carreras Sugeridas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${(results['careers'] as List).length} opciones para ti',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // MOSTRAR TODAS LAS CARRERAS con diseño moderno
                      ...(results['careers'] as List).map((career) =>
                        _buildModernCareerCard(career)
                      ).toList(),
                    ],
                  ),
                ),
              ),

              // Botones de acción modernos
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          restartTest();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Repetir Test'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen(userData: widget.userData)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: const Text('Volver al Inicio'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget moderno para tarjetas de carrera
  Widget _buildModernCareerCard(Map<String, dynamic> career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              color: primaryColor,
              size: 22,
            ),
          ),
          title: Text(
            career['name'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                career['description'],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> scores) {
    final maxValue = scores.values.reduce(max).toDouble();
    final entries = scores.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: entries.map((entry) {
                final height = max((entry.value / maxValue) * 100, 10.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            _getCategoryColor(entry.key),
                            _getCategoryColor(entry.key).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(entry.key).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryAbbreviation(entry.key),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Puntaje máximo: 7 puntos',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para abreviaturas de categorías
  String _getCategoryAbbreviation(String category) {
    switch (category) {
      case 'Realista (R)': return 'R';
      case 'Investigador (I)': return 'I';
      case 'Artístico (A)': return 'A';
      case 'Social (S)': return 'S';
      case 'Emprendedor (E)': return 'E';
      case 'Convencional (C)': return 'C';
      default: return category;
    }
  }

  Widget _buildLegendItem(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Realista (R)': return Colors.blue;
      case 'Investigador (I)': return Colors.green;
      case 'Artístico (A)': return Colors.purple;
      case 'Social (S)': return Colors.red;
      case 'Emprendedor (E)': return Colors.orange;
      case 'Convencional (C)': return Colors.teal;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Colors.purple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cargando tu progreso...',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Test Vocacional',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(userData: widget.userData)),
            );
          },
          tooltip: 'Volver al inicio',
        ),
        actions: [
          if (!testCompleted)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'save') {
                  saveProgress();
                } else if (value == 'restart') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reiniciar Test'),
                      content: const Text('¿Estás seguro de que quieres reiniciar el test? Se perderá tu progreso actual.'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            restartTest();
                          },
                          child: const Text('Reiniciar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'autosave') {
                  toggleAutoSave();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'autosave',
                  child: Row(
                    children: [
                      Icon(
                        _autoSaveEnabled ? Icons.toggle_on : Icons.toggle_off,
                        color: _autoSaveEnabled ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(_autoSaveEnabled
                        ? 'Auto-guardado: ON'
                        : 'Auto-guardado: OFF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.save, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Guardar Progreso'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'restart',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reiniciar Test'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          if (testCompleted)
            _buildModernCompletionScreen()
          else
            _buildModernQuestionScreen(),

          if (_showFeedback)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _lastAnswer == true
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernCompletionScreen() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Colors.purple],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Test Completado!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Descubre tu perfil vocacional',
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _pulseAnimation,
              child: ElevatedButton(
                onPressed: () => showResults(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Ver Mis Resultados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(userData: widget.userData)),
                );
              },
              child: Text(
                'Volver al inicio',
                style: TextStyle(fontSize: 16, color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuestionScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Indicador de progreso moderno
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pregunta ${currentQuestionIndex + 1} de 42',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _autoSaveEnabled
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _autoSaveEnabled ? Icons.cloud_done : Icons.cloud_off,
                              color: _autoSaveEnabled ? Colors.green : Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _autoSaveEnabled ? 'Guardando' : 'Manual',
                              style: TextStyle(
                                fontSize: 11,
                                color: _autoSaveEnabled ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (currentQuestionIndex + 1) / 42,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCategoryColor(_currentCategory),
                                _getCategoryColor(_currentCategory).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta de pregunta con glassmorphism (SIN CATEGORÍA)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    _getCategoryColor(_currentCategory).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _getCategoryColor(_currentCategory).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text(
                      riasecQuestions[currentQuestionIndex],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Botones de respuesta modernos
                    Row(
                      children: [
                        Expanded(
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: ElevatedButton(
                              onPressed: () => answerQuestion(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'SÍ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => answerQuestion(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'NO',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Botón de regresar a pregunta anterior (debajo de Sí/No)
                    if (currentQuestionIndex > 0)
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: goToPreviousQuestion,
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text(
                            'Regresar a pregunta anterior',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Indicador de respuestas guardadas
            if (answersHistory.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Respuestas guardadas: ${answersHistory.length} de 42',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${answersHistory.length}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}