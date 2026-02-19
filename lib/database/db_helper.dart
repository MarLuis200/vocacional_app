import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'testify.db');
    return await openDatabase(
      path,
      version: 3, // Cambia la versión a 3
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        ap TEXT,
        am TEXT,
        edad INTEGER,
        genero TEXT,
        nivel_educativo TEXT,
        intereses TEXT,
        email TEXT UNIQUE,
        contrasenia TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Sesion(
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        FOREIGN KEY(userId) REFERENCES Usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE TestResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        testType TEXT,
        resultType TEXT,
        date TEXT,
        details TEXT,
        FOREIGN KEY(userId) REFERENCES Usuarios(id)
      )
    ''');

    // Nueva tabla para el progreso del test
    await db.execute('''
      CREATE TABLE test_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        testType TEXT NOT NULL,
        currentQuestionIndex INTEGER NOT NULL,
        scores TEXT NOT NULL,
        lastUpdate TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES Usuarios (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE TestResults(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          testType TEXT,
          resultType TEXT,
          date TEXT,
          details TEXT,
          FOREIGN KEY(userId) REFERENCES Usuarios(id)
        )
      ''');
    }
    if (oldVersion < 3) {
      // Agregar la tabla de progreso en upgrades futuros
      await db.execute('''
        CREATE TABLE test_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          testType TEXT NOT NULL,
          currentQuestionIndex INTEGER NOT NULL,
          scores TEXT NOT NULL,
          lastUpdate TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES Usuarios (id)
        )
      ''');
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int> registrarUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    usuario['contrasenia'] = _hashPassword(usuario['contrasenia']);
    return await db.insert('Usuarios', usuario);
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'Usuarios',
      where: 'email = ? AND contrasenia = ?',
      whereArgs: [email, _hashPassword(password)],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> emailExiste(String email) async {
    final db = await database;
    final result = await db.query(
      'Usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<void> saveUserSession(Map<String, dynamic> usuario) async {
    final db = await database;
    await db.delete('Sesion');
    await db.insert('Sesion', {'id': 1, 'userId': usuario['id']});
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await database;
    final session = await db.query('Sesion', where: 'id = ?', whereArgs: [1]);
    if (session.isNotEmpty) {
      final userId = session.first['userId'];
      final result = await db.query('Usuarios', where: 'id = ?', whereArgs: [userId]);
      return result.isNotEmpty ? result.first : null;
    }
    return null;
  }

  Future<void> logout() async {
    final db = await database;
    await db.delete('Sesion');
  }

  Future<int> saveTestResult(Map<String, dynamic> result) async {
    final db = await database;
    final details = result['details'] ?? {};

    return await db.insert('TestResults', {
      'userId': result['userId'],
      'testType': result['testType'] ?? 'RIASEC',
      'resultType': result['resultType'] ?? 'Sin tipo',
      'date': DateTime.now().toIso8601String(),
      'details': jsonEncode(details),
    });
  }

  Future<List<Map<String, dynamic>>> getTestResults(int userId) async {
    final db = await database;
    final results = await db.query(
      'TestResults',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map((result) {
      final mappedResult = Map<String, dynamic>.from(result);
      if (mappedResult['details'] != null) {
        try {
          mappedResult['details'] = jsonDecode(mappedResult['details']);
        } catch (e) {
          mappedResult['details'] = {};
        }
      } else {
        mappedResult['details'] = {};
      }
      return mappedResult;
    }).toList();
  }

  Future<int> deleteTestResult(int resultId) async {
    final db = await database;
    return await db.delete(
      'TestResults',
      where: 'id = ?',
      whereArgs: [resultId],
    );
  }

  // Métodos para manejar el progreso del test

  Future<void> saveTestProgress(Map<String, dynamic> progressData) async {
    final db = await database;

    final scoresJson = jsonEncode(progressData['scores']);
    final existingProgress = await db.query(
      'test_progress',
      where: 'userId = ? AND testType = ?',
      whereArgs: [progressData['userId'], progressData['testType']],
    );

    if (existingProgress.isNotEmpty) {
      // Actualizar el registro existente
      await db.update(
        'test_progress',
        {
          'currentQuestionIndex': progressData['currentQuestionIndex'],
          'scores': scoresJson,
          'lastUpdate': progressData['lastUpdate'],
        },
        where: 'userId = ? AND testType = ?',
        whereArgs: [progressData['userId'], progressData['testType']],
      );
    } else {
      await db.insert(
        'test_progress',
        {
          'userId': progressData['userId'],
          'testType': progressData['testType'],
          'currentQuestionIndex': progressData['currentQuestionIndex'],
          'scores': scoresJson,
          'lastUpdate': progressData['lastUpdate'],
        },
      );
    }
  }

  Future<Map<String, dynamic>?> getTestProgress(int userId, String testType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'test_progress',
      where: 'userId = ? AND testType = ?',
      whereArgs: [userId, testType],
    );

    if (maps.isNotEmpty) {
      final progress = Map<String, dynamic>.from(maps.first);

      // Convertir el JSON string de scores de vuelta a mapa
      if (progress['scores'] != null) {
        try {
          progress['scores'] = jsonDecode(progress['scores']);
        } catch (e) {
          progress['scores'] = {
            'Realista (R)': 0,
            'Investigador (I)': 0,
            'Artístico (A)': 0,
            'Social (S)': 0,
            'Emprendedor (E)': 0,
            'Convencional (C)': 0,
          };
        }
      } else {
        progress['scores'] = {
          'Realista (R)': 0,
          'Investigador (I)': 0,
          'Artístico (A)': 0,
          'Social (S)': 0,
          'Emprendedor (E)': 0,
          'Convencional (C)': 0,
        };
      }

      return progress;
    }
    return null;
  }

  Future<void> deleteTestProgress(int userId, String testType) async {
    final db = await database;
    await db.delete(
      'test_progress',
      where: 'userId = ? AND testType = ?',
      whereArgs: [userId, testType],
    );
  }

  // 🆕 NUEVO MÉTODO AGREGADO - Obtener todos los tests en progreso de un usuario
  Future<List<Map<String, dynamic>>> getAllTestsInProgress(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'test_progress',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastUpdate DESC',
    );

    // Procesar cada progreso para convertir los scores de JSON a Map
    return maps.map((progress) {
      final processedProgress = Map<String, dynamic>.from(progress);

      if (processedProgress['scores'] != null) {
        try {
          processedProgress['scores'] = jsonDecode(processedProgress['scores']);
        } catch (e) {
          processedProgress['scores'] = {
            'Realista (R)': 0,
            'Investigador (I)': 0,
            'Artístico (A)': 0,
            'Social (S)': 0,
            'Emprendedor (E)': 0,
            'Convencional (C)': 0,
          };
        }
      }

      return processedProgress;
    }).toList();
  }
}