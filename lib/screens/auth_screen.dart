import 'package:flutter/material.dart';
import 'package:vocacional_app/screens/homescreen.dart';
import 'package:vocacional_app/database/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DBHelper();

  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apController = TextEditingController();
  final _amController = TextEditingController();
  final _edadController = TextEditingController();
  String _genero = 'Masculino';
  String _nivelEducativo = 'Preparatoria';
  final _interesesController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Animaciones
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Colores
  final Color primaryOrange = const Color(0xFFFF8C42);
  final Color secondaryOrange = const Color(0xFFFF6B35);
  final Color deepNavy = const Color(0xFF1A2639);
  final Color softNavy = const Color(0xFF2C3E50);
  final Color pureWhite = const Color(0xFFFFFFFF);
  final Color offWhite = const Color(0xFFF8F9FA);
  final Color softBlue = const Color(0xFF4A90E2);
  final Color softGreen = const Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apController.dispose();
    _amController.dispose();
    _edadController.dispose();
    _interesesController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _isPasswordComplex(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> _showNotification(BuildContext context, String message, bool isError) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: pureWhite,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[400] : softGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        final hashedPassword = _hashPassword(_passwordController.text);
        final usuario = await dbHelper.login(_emailController.text, hashedPassword);

        if (!mounted) return;

        if (usuario != null) {
          await dbHelper.saveUserSession(usuario);

          await _fadeController.reverse();

          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomeScreen(userData: usuario),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          }

          await _showNotification(context, '¡Bienvenido! ✨', false);
        } else {
          await _showNotification(context, '❌ Credenciales incorrectas', true);
        }
      } else {
        if (await dbHelper.emailExiste(_emailController.text)) {
          await _showNotification(context, '⚠️ Este email ya está registrado', true);
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          await _showNotification(context, '❌ Las contraseñas no coinciden', true);
          return;
        }

        if (!_isPasswordComplex(_passwordController.text)) {
          await _showNotification(context,
              '🔒 La contraseña debe tener: 8+ caracteres, mayúscula, minúscula, número y carácter especial',
              true);
          return;
        }

        final usuario = {
          'nombre': _nombreController.text,
          'ap': _apController.text,
          'am': _amController.text,
          'edad': int.parse(_edadController.text),
          'genero': _genero,
          'nivel_educativo': _nivelEducativo,
          'intereses': _interesesController.text,
          'email': _emailController.text,
          'contrasenia': _hashPassword(_passwordController.text),
        };

        await dbHelper.registrarUsuario(usuario);
        await _showNotification(context, '✅ Registro exitoso. ¡Bienvenido!', false);

        setState(() {
          isLogin = true;
          _formKey.currentState?.reset();
        });

        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
      }
    } catch (e) {
      await _showNotification(context, 'Error: ${e.toString()}', true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: offWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              offWhite,
              pureWhite,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width > 600 ? size.width * 0.2 : 24,
                vertical: 20,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Encabezado con gradiente
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryOrange,
                                secondaryOrange,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryOrange.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            pureWhite.withOpacity(0.3),
                                            pureWhite.withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: pureWhite,
                                          width: 3,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.auto_stories,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isLogin ? '¡Bienvenido!' : 'Crea tu cuenta',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLogin
                                    ? 'Accede a tu orientación vocacional'
                                    : 'Comienza tu viaje vocacional',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Formulario
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: pureWhite,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: deepNavy.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: !isLogin
                                    ? _buildRegisterFields()
                                    : _buildLoginFields(),
                              ),

                              const SizedBox(height: 32),

                              // Botón principal
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: _isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [deepNavy, softNavy],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [deepNavy, softNavy],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: deepNavy.withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isLogin ? 'INGRESAR' : 'CREAR CUENTA',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  isLogin
                                                      ? Icons.arrow_forward
                                                      : Icons.person_add,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 20),

                              // Botón de cambio
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                    _formKey.currentState?.reset();
                                  });
                                  _fadeController.forward(from: 0);
                                  _slideController.forward(from: 0);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: deepNavy,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: softBlue.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isLogin ? Icons.person_add_outlined : Icons.login_outlined,
                                      size: 20,
                                      color: softBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: isLogin
                                                ? '¿Nuevo aquí? '
                                                : '¿Ya tienes cuenta? ',
                                            style: TextStyle(
                                              color: deepNavy.withOpacity(0.7),
                                              fontSize: 15,
                                            ),
                                          ),
                                          TextSpan(
                                            text: isLogin ? 'Regístrate' : 'Inicia sesión',
                                            style: TextStyle(
                                              color: softBlue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        _buildAnimatedField(
          index: 0,
          child: TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              helperText: 'ejemplo@correo.com',
              helperStyle: TextStyle(
                color: deepNavy.withOpacity(0.4),
                fontSize: 11,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: softBlue,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu correo';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Correo no válido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: 1,
          child: TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: softBlue,
                size: 22,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: softBlue.withOpacity(0.7),
                    size: 22,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            obscureText: !_showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showNotification(context, 'Función en desarrollo 🔧', false);
            },
            style: TextButton.styleFrom(
              foregroundColor: softBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    int fieldIndex = 0;

    return Column(
      children: [
        if (isWide)
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  index: fieldIndex++,
                  child: _buildNameField('Nombre(s)', _nombreController),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnimatedField(
                  index: fieldIndex++,
                  child: _buildNameField('Apellido Paterno', _apController),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnimatedField(
                  index: fieldIndex++,
                  child: _buildNameField('Apellido Materno', _amController),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildAnimatedField(
                index: fieldIndex++,
                child: _buildNameField('Nombre(s)', _nombreController),
              ),
              const SizedBox(height: 20),
              _buildAnimatedField(
                index: fieldIndex++,
                child: _buildNameField('Apellido Paterno', _apController),
              ),
              const SizedBox(height: 20),
              _buildAnimatedField(
                index: fieldIndex++,
                child: _buildNameField('Apellido Materno', _amController),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedField(
                index: fieldIndex++,
                child: TextFormField(
                  controller: _edadController,
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    labelStyle: TextStyle(
                      color: deepNavy.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: '12-100 años',
                    helperStyle: TextStyle(
                      color: deepNavy.withOpacity(0.4),
                      fontSize: 11,
                    ),
                    prefixIcon: Icon(
                      Icons.cake_outlined,
                      color: softBlue,
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: offWhite,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Edad requerida';
                    }
                    final edad = int.tryParse(value);
                    if (edad == null || edad < 5 || edad > 100) {
                      return 'Edad no válida';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedField(
                index: fieldIndex++,
                child: DropdownButtonFormField<String>(
                  value: _genero,
                  decoration: InputDecoration(
                    labelText: 'Género',
                    labelStyle: TextStyle(
                      color: deepNavy.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: softBlue,
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: offWhite,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                  ),
                  dropdownColor: pureWhite,
                  style: TextStyle(color: deepNavy),
                  icon: Icon(Icons.arrow_drop_down, color: softBlue, size: 24),
                  items: const [
                    DropdownMenuItem(
                      value: 'Masculino',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'Femenino',
                      child: Text('Femenino'),
                    ),
                    DropdownMenuItem(
                      value: 'Prefiero no decir',
                      child: Text('Prefiero no decir'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _genero = value!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: fieldIndex++,
          child: DropdownButtonFormField<String>(
            value: _nivelEducativo,
            decoration: InputDecoration(
              labelText: 'Nivel Educativo',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.school_outlined,
                color: softBlue,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 20,
              ),
            ),
            dropdownColor: pureWhite,
            style: TextStyle(color: deepNavy),
            icon: Icon(Icons.arrow_drop_down, color: softBlue, size: 24),
            items: const [
              DropdownMenuItem(
                value: 'Primaria',
                child: Text('Primaria'),
                          ),
              DropdownMenuItem(
              value: 'Secundaria',
              child: Text('Secundaria'),
              ),
              DropdownMenuItem(
                value: 'Preparatoria',
                child: Text('Preparatoria'),
              ),
              DropdownMenuItem(
                value: 'Universidad',
                child: Text('Universidad'),
              ),
              DropdownMenuItem(
                value: 'Posgrado',
                child: Text('Posgrado'),
              ),
            ],
            onChanged: (value) => setState(() => _nivelEducativo = value!),
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: fieldIndex++,
          child: TextFormField(
            controller: _interesesController,
            decoration: InputDecoration(
              labelText: 'Intereses profesionales',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              helperText: 'Ej: medicina, arte, tecnología...',
              helperStyle: TextStyle(
                color: deepNavy.withOpacity(0.4),
                fontSize: 11,
              ),
              prefixIcon: Icon(
                Icons.auto_awesome_outlined,
                color: softBlue,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cuéntanos tus intereses';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: fieldIndex++,
          child: TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              helperText: 'Recibirás información importante',
              helperStyle: TextStyle(
                color: deepNavy.withOpacity(0.4),
                fontSize: 11,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: softBlue,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Correo requerido';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Correo no válido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: fieldIndex++,
          child: TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              helperText: 'Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial',
              helperStyle: TextStyle(
                color: deepNavy.withOpacity(0.4),
                fontSize: 11,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: softBlue,
                size: 22,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: softBlue.withOpacity(0.7),
                    size: 22,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            obscureText: !_showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Contraseña requerida';
              }
              if (!_isPasswordComplex(value)) {
                return 'Contraseña débil';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          index: fieldIndex++,
          child: TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              labelStyle: TextStyle(
                color: deepNavy.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: softBlue,
                size: 22,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: softBlue.withOpacity(0.7),
                    size: 22,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: deepNavy.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: offWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
            obscureText: !_showConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),
        _PasswordStrengthIndicator(
          password: _passwordController.text,
          isVisible: !isLogin && _passwordController.text.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildNameField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: deepNavy.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: softBlue,
          size: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: deepNavy.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: deepNavy.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.blue,  // CAMBIADO: softBlue -> Colors.blue
            width: 2,
          ),
        ),
        filled: true,
        fillColor: offWhite,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        if (value.length < 2) {
          return 'Mínimo 2 caracteres';
        }
        return null;
      },
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool isVisible;

  const _PasswordStrengthIndicator({
    required this.password,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final color = _getColor(strength);
    final text = _getText(strength);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(strength),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _getWidthFactor(strength),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score;
  }

  Color _getColor(int strength) {
    if (strength <= 2) return Colors.red;
    if (strength <= 4) return Colors.orange;
    return Colors.green;
  }

  String _getText(int strength) {
    if (strength <= 2) return 'Contraseña débil';
    if (strength <= 4) return 'Contraseña media';
    return 'Contraseña fuerte';
  }

  double _getWidthFactor(int strength) {
    if (strength <= 2) return 0.33;
    if (strength <= 4) return 0.66;
    return 1.0;
  }

  IconData _getIcon(int strength) {
    if (strength <= 2) return Icons.warning_amber_rounded;
    if (strength <= 4) return Icons.info_outline;
    return Icons.check_circle_outline;
  }
}