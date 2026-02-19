import 'package:flutter/material.dart';
import 'package:vocacional_app/screens/quizscreen.dart';
import 'package:vocacional_app/database/db_helper.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late String _userName;
  final dbHelper = DBHelper();
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  // 🎨 NUEVA PALETA DE COLORES - Tecnológico de Estudios Superiores de Valle de Bravo
  static const Color azulRey = Color(0xFF003A6B);      // Azul institucional principal
  static const Color azulClaro = Color(0xFF1E4F8A);    // Variante más clara
  static const Color azulOscuro = Color(0xFF002244);   // Variante más oscura
  static const Color naranja = Color(0xFFFF6B00);      // Naranja acento
  static const Color naranjaClaro = Color(0xFFFF8C33);  // Naranja suave
  static const Color gris = Color(0xFF6C757D);         // Gris para textos
  static const Color grisClaro = Color(0xFFE9ECEF);    // Gris para fondos
  static const Color backgroundColor = Color(0xFFF5F7FA); // Fondo general

  // Mantenemos algunos colores neutros
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _userName = widget.userData['nombre'] ?? 'Usuario';

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await dbHelper.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  // 🆕 NUEVO MÉTODO: Mostrar diálogo para elegir entre continuar test o crear nuevo
  Future<void> _showTestOptions(BuildContext context) async {
    // Primero obtener todos los tests en progreso
    final testsInProgress = await dbHelper.getAllTestsInProgress(widget.userData['id']);

    if (testsInProgress.isEmpty) {
      // Si no hay tests en progreso, ir directamente al QuizScreen
      _startNewTest();
      return;
    }

    // Mostrar diálogo con opciones
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gris.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [azulRey, naranja],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Vocacional',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tienes ${testsInProgress.length} test en progreso',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Lista de tests en progreso
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: testsInProgress.length,
                itemBuilder: (context, index) {
                  final test = testsInProgress[index];
                  final date = DateTime.parse(test['lastUpdate']);
                  final formattedDate = '${date.day}/${date.month}/${date.year}';
                  final progress = ((test['currentQuestionIndex'] + 1) / 42 * 100).round();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: grisClaro,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: azulRey.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: azulRey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: azulRey,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        'Test RIASEC',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Pregunta ${test['currentQuestionIndex'] + 1} de 42',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (test['currentQuestionIndex'] + 1) / 42,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(naranja),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Último: $formattedDate • $progress%',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _continueTest(test);
                      },
                    ),
                  );
                },
              ),
            ),
            // Opción para nuevo test
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewTest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: naranja,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text(
                      'Comenzar nuevo test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 NUEVO MÉTODO: Continuar un test existente - SOLO ESTO CAMBIÓ
  void _continueTest(Map<String, dynamic> testProgress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          userData: widget.userData,
          initialProgress: testProgress, // 👈 Esto pasa el progreso guardado
          startNew: false, // 👈 Importante: indicar que no es nuevo
        ),
      ),
    );
  }

  // 🆕 NUEVO MÉTODO: Iniciar test nuevo - SOLO ESTO CAMBIÓ
  void _startNewTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          userData: widget.userData,
          startNew: true, // 👈 Importante: indicar que es nuevo
        ),
      ),
    );
  }

  void _showTestInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: gris.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [azulRey, naranja],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Test RIASEC',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        '¿Qué es el test RIASEC?',
                        'Los códigos RIASEC son una forma de clasificar a las personas según sus intereses para que puedan encontrar las carreras profesionales adecuadas. El sistema fue desarrollado por el Dr. John L. Holland, psicólogo académico.',
                        Icons.lightbulb_outline,
                        azulRey,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Las 6 categorías:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryCardModern(
                        'REALISTA',
                        'Trabajos que requieren habilidades manuales, herramientas y máquinas.',
                        Colors.blue,
                        Icons.build,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCardModern(
                        'INVESTIGADOR',
                        'Trabajos que implican teorías, investigación y resolución de problemas científicos.',
                        Colors.green,
                        Icons.science,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCardModern(
                        'ARTÍSTICO',
                        'Trabajos creativos que involucran arte, diseño, escritura y autoexpresión.',
                        Colors.purple,
                        Icons.palette,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCardModern(
                        'SOCIAL',
                        'Trabajos que implican ayudar, enseñar y servir a otras personas.',
                        Colors.red,
                        Icons.people,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCardModern(
                        'EMPRENDEDOR',
                        'Trabajos que implican liderar, influir y persuadir a otros.',
                        naranja,
                        Icons.trending_up,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCardModern(
                        'CONVENCIONAL',
                        'Trabajos que implican organización, datos y procedimientos estructurados.',
                        Colors.teal,
                        Icons.assignment_turned_in,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCardModern(String title, String description, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fondo con formas geométricas en azul y naranja
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: azulRey.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: naranja.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -30,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: azulClaro.withOpacity(0.05),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con saludo y avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola,',
                              style: TextStyle(
                                fontSize: 24,
                                color: gris,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: azulRey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: azulRey.withOpacity(0.1),
                            child: Text(
                              _userName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: azulRey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Card principal con animación - con gradiente azul
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: azulRey.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    azulRey.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: azulRey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Descubre tu vocación',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Encuentra la carrera perfecta para ti con nuestro test basado en la metodología RIASEC',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: gris,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/student.png',
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 🆕 BOTÓN PRINCIPAL DEL TEST ACTUALIZADO
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          gradient: const LinearGradient(
                            colors: [azulRey, naranja],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: azulRey.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(35),
                            onTap: () => _showTestOptions(context), // 👈 NUEVO: Muestra opciones
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Realizar Test Vocacional',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de acción horizontales
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernActionButton(
                            icon: Icons.info_outline,
                            label: '¿Qué es?',
                            onPressed: () => _showTestInfo(context),
                            color: azulRey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernActionButton(
                            icon: Icons.person_outline,
                            label: 'Mi perfil',
                            onPressed: () => _showUserProfile(context),
                            color: naranja,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sección de logout
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _logout(context),
                        icon: Icon(
                          Icons.logout,
                          color: gris,
                          size: 20,
                        ),
                        label: Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: gris,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sección de consejos vocacionales
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: azulRey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.tips_and_updates,
                                  color: azulRey,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Consejos vocacionales',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildModernTip(
                            icon: Icons.search,
                            iconColor: azulRey,
                            title: 'Explora tus intereses',
                            description: 'Identifica las actividades que realmente disfrutas y en las que destacas naturalmente.',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFEEEEEE)),
                          ),
                          _buildModernTip(
                            icon: Icons.school,
                            iconColor: naranja,
                            title: 'Investiga carreras',
                            description: 'Conoce a fondo las opciones profesionales que te interesan y sus requisitos.',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFEEEEEE)),
                          ),
                          _buildModernTip(
                            icon: Icons.people,
                            iconColor: azulClaro,
                            title: 'Conecta con profesionales',
                            description: 'Habla con personas que trabajen en áreas de tu interés para conocer su experiencia.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: gris,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQuizConfirmation(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: '¿Listo/a para comenzar?',
      text: 'El test RIASEC te ayudará a descubrir tu verdadera vocación profesional',
      confirmBtnText: '¡Comenzar!',
      cancelBtnText: 'Más tarde',
      confirmBtnColor: azulRey,
      backgroundColor: Colors.white,
      titleColor: textPrimary,
      textColor: textSecondary,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _startNewTest(); // 👈 Ahora usa el método correcto
      },
    );
  }

  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gris.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [azulRey, naranja],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Perfil de $_userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Datos del usuario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildProfileInfoRow('Nombre completo', '${widget.userData['nombre']} ${widget.userData['ap']} ${widget.userData['am']}'),
                    const Divider(height: 16),
                    _buildProfileInfoRow('Edad', '${widget.userData['edad']} años'),
                    const Divider(height: 16),
                    _buildProfileInfoRow('Género', '${widget.userData['genero']}'),
                    const Divider(height: 16),
                    _buildProfileInfoRow('Correo', '${widget.userData['email']}'),
                    const Divider(height: 16),
                    _buildProfileInfoRow('Intereses', '${widget.userData['intereses']}'),
                    const Divider(height: 16),
                    _buildProfileInfoRow('Nivel educativo', '${widget.userData['nivel_educativo']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 🆕 SECCIÓN DE TESTS EN PROGRESO
            FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getAllTestsInProgress(widget.userData['id']),
              builder: (context, progressSnapshot) {
                if (progressSnapshot.hasData && progressSnapshot.data!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle, color: azulRey, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tests en progreso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.only(left: 24),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: progressSnapshot.data!.length,
                          itemBuilder: (context, index) {
                            final test = progressSnapshot.data![index];
                            final progress = ((test['currentQuestionIndex'] + 1) / 42 * 100).round();

                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [azulRey.withOpacity(0.1), naranja.withOpacity(0.1)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: azulRey.withOpacity(0.2),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _continueTest(test),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.play_arrow, color: naranja, size: 16),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Test RIASEC',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Pregunta ${test['currentQuestionIndex'] + 1}/42',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: gris,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: (test['currentQuestionIndex'] + 1) / 42,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(naranja),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$progress%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: azulRey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Historial de resultados
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.history, color: azulRey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Historial de resultados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getTestResults(widget.userData['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: azulRey));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: gris.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay resultados guardados',
                            style: TextStyle(
                              color: gris,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final results = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final date = DateTime.parse(result['date']);
                      final formattedDate = '${date.day}/${date.month}/${date.year}';

                      Map<String, dynamic> details;
                      try {
                        details = result['details'] is String
                            ? json.decode(result['details'])
                            : (result['details'] as Map?) ?? {};
                      } catch (e) {
                        details = {};
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: gris.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: azulRey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assessment,
                              color: azulRey,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Test RIASEC',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Perfil: ${details['dominantCategory'] ?? 'No disponible'}',
                                style: TextStyle(color: gris, fontSize: 13),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(color: gris, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmDeleteResult(context, result['id']),
                          ),
                          onTap: () => _showResultDetails(context, details, formattedDate),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: gris,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showResultDetails(BuildContext context, Map<String, dynamic> details, String date) {
    Map<String, int> scores = {};
    if (details['scores'] != null) {
      final dynamicScores = details['scores'] as Map<String, dynamic>;
      scores = dynamicScores.map<String, int>((key, value) {
        return MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0);
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gris.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [azulRey, naranja],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultado del $date',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Test RIASEC',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Perfil dominante
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            azulRey.withOpacity(0.1),
                            naranja.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: azulRey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: azulRey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.stars,
                              color: azulRey,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tu perfil dominante',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  details['dominantCategory'] ?? 'No disponible',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: azulRey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gráfico de barras
                    if (scores.isNotEmpty) ...[
                      const Text(
                        'Puntajes por categoría',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBarChart(scores),
                      const SizedBox(height: 16),

                      // Leyenda
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
                          _buildLegendItem(naranja, 'Emprendedor'),
                          _buildLegendItem(Colors.teal, 'Convencional'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Carreras sugeridas
                    if (details['careers'] != null && (details['careers'] as List).isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.school, color: azulRey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Carreras sugeridas (${(details['careers'] as List).length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...(details['careers'] as List).map((career) =>
                        _buildCareerResultCard(career)
                      ).toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerResultCard(Map<String, dynamic> career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gris.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: azulRey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              color: azulRey,
              size: 20,
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
                color: Colors.grey[50],
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
                  color: gris,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                      width: 35,
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
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(entry.key).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 35,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
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
                        color: gris,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryAbbreviation(String category) {
    switch (category) {
      case 'Realista (R)': return 'R';
      case 'Investigador (I)': return 'I';
      case 'Artístico (A)': return 'A';
      case 'Social (S)': return 'S';
      case 'Emprendedor (E)': return 'E';
      case 'Convencional (C)': return 'C';
      default: return category.substring(0, 1);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Realista (R)': return Colors.blue;
      case 'Investigador (I)': return Colors.green;
      case 'Artístico (A)': return Colors.purple;
      case 'Social (S)': return Colors.red;
      case 'Emprendedor (E)': return naranja;
      case 'Convencional (C)': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Widget _buildLegendItem(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            style: const TextStyle(fontSize: 12, color: gris),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteResult(BuildContext context, int resultId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar resultado'),
        content: const Text('¿Estás seguro de que quieres eliminar este resultado?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await dbHelper.deleteTestResult(resultId);
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Resultado eliminado correctamente'),
              backgroundColor: naranja,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}