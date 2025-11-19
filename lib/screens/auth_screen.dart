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

class _AuthScreenState extends State<AuthScreen> {
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

  // Paleta de colores
  final Color orange = const Color(0xFFE67E22); // Naranja
  final Color navy = const Color(0xFF2C3E50);  // Azul marino
  final Color white = const Color(0xFFFFFFFF);  // Blanco
  final Color lightBlue = const Color(0xFF3498DB); // Azul claro para efectos

  @override
  void dispose() {
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

  // Métodos _hashPassword y _showNotification se mantienen igual
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _showNotification(BuildContext context, String message, bool isError) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[800] : Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(userData: usuario),
            ),
          );
          await _showNotification(context, 'Inicio de sesión exitoso', false);
        } else {
          await _showNotification(context, 'Credenciales incorrectas', true);
        }
      } else {
        if (await dbHelper.emailExiste(_emailController.text)) {
          await _showNotification(context, 'Este email ya está registrado', true);
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          await _showNotification(context, 'Las contraseñas no coinciden', true);
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
        await _showNotification(context, 'Registro exitoso. Por favor inicia sesión', false);

        setState(() {
          isLogin = true;
          _formKey.currentState?.reset();
        });
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
      backgroundColor: white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width > 600 ? size.width * 0.2 : 24,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado naranja
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: white.withOpacity(0.2),
                            border: Border.all(
                              color: white,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.school,
                            size: 40,
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isLogin ? 'Inicio de Sesión' : 'Registro',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Formulario
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!isLogin) _buildRegisterFields(context),
                        if (isLogin) _buildLoginFields(context),

                        const SizedBox(height: 28),
                        // Botón azul marino mejorado
                        SizedBox(
                          height: 50,
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(navy),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: navy,
                                    foregroundColor: white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shadowColor: navy.withOpacity(0.3),
                                    // Efecto de gradiente sutil
                                    side: BorderSide(
                                      color: lightBlue.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Text(
                                      isLogin ? 'INGRESAR' : 'REGISTRARSE',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        // Botón secundario con estilo moderno
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                              _formKey.currentState?.reset();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: navy,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: navy.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: isLogin
                                      ? '¿No tienes cuenta? '
                                      : '¿Ya tienes cuenta? ',
                                  style: TextStyle(
                                    color: navy.withOpacity(0.8),
                                  ),
                                ),
                                TextSpan(
                                  text: isLogin ? 'Regístrate' : 'Inicia sesión',
                                  style: TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildLoginFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration(
            label: 'Correo electrónico',
            icon: Icons.email,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo';
            }
            if (!value.contains('@')) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          decoration: _buildPasswordInputDecoration(
            label: 'Contraseña',
            icon: Icons.lock,
            showPassword: _showPassword,
            onToggle: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          obscureText: !_showPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRegisterFields(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Column(
      children: [
        if (isWide)
          Row(
            children: [
              Expanded(child: _buildNameField('Nombre(s)', _nombreController)),
              const SizedBox(width: 16),
              Expanded(child: _buildNameField('Apellido Paterno', _apController)),
              const SizedBox(width: 16),
              Expanded(child: _buildNameField('Apellido Materno', _amController)),
            ],
          )
        else
          Column(
            children: [
              _buildNameField('Nombre(s)', _nombreController),
              const SizedBox(height: 20),
              _buildNameField('Apellido Paterno', _apController),
              const SizedBox(height: 20),
              _buildNameField('Apellido Materno', _amController),
            ],
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _edadController,
                decoration: _buildInputDecoration(
                  label: 'Edad',
                  icon: Icons.calendar_today,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu edad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Edad no válida';
                  }
                  if (int.parse(value) < 12 || int.parse(value) > 100) {
                    return 'Edad no válida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _genero,
                decoration: _buildInputDecoration(
                  label: 'Género',
                  icon: Icons.person_outline,
                ),
                dropdownColor: white,
                style: TextStyle(color: navy),
                icon: Icon(Icons.arrow_drop_down, color: navy),
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
                    value: 'Otro',
                    child: Text('Otro'),
                  ),
                ],
                onChanged: (value) => setState(() => _genero = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _nivelEducativo,
          decoration: _buildInputDecoration(
            label: 'Nivel Educativo',
            icon: Icons.school,
          ),
          dropdownColor: white,
          style: TextStyle(color: navy),
          icon: Icon(Icons.arrow_drop_down, color: navy),
          items: const [
            DropdownMenuItem(
              value: 'Preparatoria',
              child: Text('Preparatoria'),
            ),
            DropdownMenuItem(
              value: 'Universidad',
              child: Text('Universidad'),
            ),
          ],
          onChanged: (value) => setState(() => _nivelEducativo = value!),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _interesesController,
          decoration: _buildInputDecoration(
            label: 'Intereses (separados por comas)',
            icon: Icons.interests,
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Describe tus intereses';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration(
            label: 'Correo electrónico',
            icon: Icons.email,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo';
            }
            if (!value.contains('@')) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          decoration: _buildPasswordInputDecoration(
            label: 'Contraseña',
            icon: Icons.lock,
            showPassword: _showPassword,
            onToggle: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          obscureText: !_showPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: _buildPasswordInputDecoration(
            label: 'Confirmar Contraseña',
            icon: Icons.lock_outline,
            showPassword: _showConfirmPassword,
            onToggle: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
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
      ],
    );
  }

  Widget _buildNameField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(
        label: label,
        icon: Icons.person,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: navy.withOpacity(0.6),
      ),
      floatingLabelStyle: TextStyle(
        color: navy,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(
        icon,
        color: navy.withOpacity(0.7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy,
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    );
  }

  // MÉTODO CORREGIDO - SOLO ICONO INTERACTIVO
  InputDecoration _buildPasswordInputDecoration({
    required String label,
    required IconData icon,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: navy.withOpacity(0.6),
      ),
      floatingLabelStyle: TextStyle(
        color: navy,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(
        icon,
        color: navy.withOpacity(0.7),
      ),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Icon(
          showPassword ? Icons.visibility : Icons.visibility_off,
          color: navy.withOpacity(0.6),
          size: 20,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: navy,
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    );
  }
}