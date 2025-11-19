import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/auth_screen.dart';
import 'screens/homescreen.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa sqflite_common_ffi si estás en escritorio (Windows, macOS, Linux)
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Verificar sesión existente al iniciar
  final dbHelper = DBHelper();
  final currentUser = await dbHelper.getCurrentUser();

  runApp(MyApp(isLoggedIn: currentUser != null));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Vocacional',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      initialRoute: isLoggedIn ? '/home' : '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(userData: userData ?? {});
        },
      },
      // Manejo de rutas no definidas
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    const primaryColor = Color.fromRGBO(107, 43, 0, 1);
    const secondaryColor = Color.fromARGB(255, 255, 236, 192);
    const backgroundColor = Color.fromARGB(255, 223, 255, 225);

    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 255, 236, 192),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
        cardTheme: CardThemeData(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(10),
      ),
      useMaterial3: true,
    );
  }
}