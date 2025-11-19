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

  @override
  void initState() {
    super.initState();
    _userName = widget.userData['nombre'] ?? 'Usuario';

    // Controlador para la animación de escala (pulsación)
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

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
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

  // FUNCIÓN _showTestInfo CORREGIDA Y MOVIDA DENTRO DE LA CLASE
  void _showTestInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[50]!,
                  Colors.white,
                  Colors.green[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con animación
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ícono animado de interrogación
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Test RIASEC',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido con scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedParagraph(
                          'Los códigos RIASEC son una forma de clasificar a las personas según sus intereses para que puedan encontrar las carreras profesionales adecuadas. El sistema fue desarrollado por el Dr. John L. Holland, psicólogo académico. La teoría del Dr. Holland propone que existen seis áreas generales en las que se pueden clasificar todas las carreras profesionales. Estas mismas seis áreas pueden utilizarse para describir a las personas, sus personalidades e intereses.',
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryCard(
                          'REALISTA 🔧',
                          Colors.orange,
                          Icons.build,
                          'Las personas realistas suelen estar interesadas en trabajos de construcción que requieren el uso de herramientas, máquinas o habilidades físicas. A los constructores les gusta trabajar con con plantas , animales, y al aire libre.',
                        ),
                        _buildCategoryCard(
                          'INVESTIGACIÓN 🔬',
                          Colors.purple,
                          Icons.science,
                          'Los trabajos de investigación implican teorías, investigación e indagación intelectual. A las personas con vocación investigadora les gusta trabajar con ideas , conceptos, y disfrutan de la ciencia, la tecnología y el mundo académico.',
                        ),
                        _buildCategoryCard(
                          'ARTÍSTICO 🎨',
                          Colors.pink,
                          Icons.palette,
                          'Los trabajos artísticos involucran arte, diseño, lenguaje y autoexpresión. A las personas artísticas les gusta trabajar en entornos informales y crear algo único.',
                        ),
                        _buildCategoryCard(
                          'SOCIAL 🤝',
                          Colors.green,
                          Icons.people,
                          'Los trabajos sociales implican ayudar, enseñar, entrenar y servir a otras personas. A las personas sociales les gusta trabajar en entornos de cooperación para mejorar la vida de los demás.',
                        ),
                        _buildCategoryCard(
                          'EMPRENDIMIENTO 💼',
                          Colors.red,
                          Icons.business_center,
                          'Los trabajos emprendedores implican liderar, motivar e influir en los demás. Las personas emprendedoras disfrutan trabajando en puestos de poder para tomar decisiones y llevar a cabo proyectos.',
                        ),
                        _buildCategoryCard(
                          'CONVENCIONAL 📊',
                          Colors.blue,
                          Icons.assignment,
                          'Los trabajos convencionales implican la gestión de datos, información y procesos. A las personas convencionales les gusta trabajar en entornos estructurados para completar las tareas con precisión y exactitud.',
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer con botón
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.blue[300],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ENTENDIDO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MÉTODOS AUXILIARES PARA _showTestInfo
  Widget _buildAnimatedParagraph(String text) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color, IconData icon, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: color.withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final brightness = SchedulerBinding.instance.window.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFFF5F5F5)
          : const Color(0xFFF8FDFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FDFF),
                    Color(0xFFE6F7FF),
                  ],
                ),
              ),
            ),
          ),

          // Elementos decorativos naturales
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50]!.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[50]!.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 50,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Icon(Icons.nature, size: 60, color: Colors.green[100]!.withOpacity(0.5)),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 50,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Icon(Icons.lightbulb_outline, size: 60, color: Colors.amber[100]!.withOpacity(0.5)),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // AppBar personalizado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola,',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.grey[800]),
                          onPressed: () => _logout(context),
                          tooltip: 'Cerrar sesión',
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '🌟 Bienvenido/a a App Vocacional',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Descubre tu perfil profesional con nuestro test RIASEC y encuentra carreras que se adapten a tu personalidad.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/student.png',
                                      height: 120,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón principal del test con animación
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: ElevatedButton(
                        onPressed: () => _showQuizConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Realizar Test Vocacional',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.info_outline,
                          label: '¿Qué es?',
                          onPressed: () => _showTestInfo(context),
                          color: Colors.teal[400]!,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.person_outline,
                          label: 'Mi perfil',
                          onPressed: () => _showUserProfile(context),
                          color: Colors.orange[400]!,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildTipsSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Flexible(
      child: TextButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          elevation: 4,
          shadowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejos Vocacionales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                _buildTipItem(
                  icon: Icons.search,
                  title: "Explora tus intereses",
                  description: "Piensa en las actividades que más disfrutas y en qué eres bueno.",
                ),
                const Divider(height: 20),
                _buildTipItem(
                  icon: Icons.school,
                  title: "Investiga carreras",
                  description: "Busca información sobre diferentes profesiones y sus requisitos.",
                ),
                const Divider(height: 20),
                _buildTipItem(
                  icon: Icons.people,
                  title: "Habla con profesionales",
                  description: "Conoce experiencias reales de personas en diferentes campos.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal[400], size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
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
      title: '¿Estás listo/a?',
      text: 'El test RIASEC te ayudará a descubrir tu perfil vocacional',
      confirmBtnText: 'Comenzar',
      cancelBtnText: 'Después',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(userData: widget.userData),
          ),
        );
      },
    );
  }

  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perfil de $_userName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Text('Nombre: ${widget.userData['nombre']} ${widget.userData['ap']}'),
            Text('Edad: ${widget.userData['edad']}'),
            Text('Género: ${widget.userData['genero']}'),
            Text('Nivel educativo: ${widget.userData['nivel_educativo']}'),

            const SizedBox(height: 20),
            const Divider(),

            const Text(
              'Historial de Resultados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getTestResults(widget.userData['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay resultados guardados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final results = snapshot.data!;
                  return ListView.builder(
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

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text('Test ${result['testType']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Perfil: ${details['dominantCategory'] ?? 'No disponible'}'),
                              Text('Fecha: $formattedDate',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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

  // NUEVO MÉTODO _showResultDetails ACTUALIZADO
  void _showResultDetails(BuildContext context, Map<String, dynamic> details, String date) {
    // Convertir los scores de dynamic a int
    Map<String, int> scores = {};
    if (details['scores'] != null) {
      final dynamicScores = details['scores'] as Map<String, dynamic>;
      scores = dynamicScores.map<String, int>((key, value) {
        return MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0);
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del diálogo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Resultado del $date',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Test RIASEC',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Perfil dominante
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.deepPurple,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu perfil dominante es:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    details['dominantCategory'] ?? 'No disponible',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gráfico de barras
                      if (scores.isNotEmpty) ...[
                        const Text(
                          'Puntajes por Categoría',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 180,
                          child: _buildBarChart(scores),
                        ),
                        const SizedBox(height: 15),

                        // Leyenda
                        const Text(
                          'Leyenda:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            _buildLegendItem(Colors.blue, 'Realista (R)'),
                            _buildLegendItem(Colors.green, 'Investigador (I)'),
                            _buildLegendItem(Colors.purple, 'Artístico (A)'),
                            _buildLegendItem(Colors.red, 'Social (S)'),
                            _buildLegendItem(Colors.orange, 'Emprendedor (E)'),
                            _buildLegendItem(Colors.teal, 'Convencional (C)'),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Carreras sugeridas
                      if (details['careers'] != null && (details['careers'] as List).isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.deepPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carreras Sugeridas (${(details['careers'] as List).length})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    Text(
                                      'Todas las carreras para tu perfil ${details['dominantCategory']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Mostrar todas las carreras
                        ...(details['careers'] as List).map((career) =>
                          _buildCareerResultCard(career)
                        ).toList(),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No hay carreras sugeridas disponibles',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Botones de acción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NUEVOS MÉTODOS AUXILIARES PARA EL DISEÑO ACTUALIZADO

  // Widget para tarjetas de carrera en resultados (igual que en QuizScreen)
  Widget _buildCareerResultCard(Map<String, dynamic> career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.work_outline,
            color: Colors.deepPurple,
            size: 20,
          ),
        ),
        title: Text(
          career['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              career['description'],
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Gráfico de barras actualizado (igual que en QuizScreen)
  Widget _buildBarChart(Map<String, int> scores) {
    final maxValue = scores.values.reduce(max).toDouble();
    final entries = scores.entries.toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: entries.map((entry) {
                  final height = max((entry.value / maxValue) * 80, 8.0);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 25,
                        height: height,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key),
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _getCategoryColor(entry.key).withOpacity(0.8),
                              _getCategoryColor(entry.key),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 40,
                        child: Text(
                          _getCategoryAbbreviation(entry.key),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Puntaje máximo posible: 7',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
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

  // Método para obtener el color de cada categoría
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

  // Método para construir elementos de leyenda
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _confirmDeleteResult(BuildContext context, int resultId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este resultado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
            const SnackBar(
              content: Text('Resultado eliminado correctamente'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}