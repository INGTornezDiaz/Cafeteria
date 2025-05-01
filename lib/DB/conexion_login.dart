import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabase() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Initialize the database factory for desktop platforms
    initializeDatabase();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'comedor.db');

    // Crear o abrir la base de datos con onCreate para crear las tablas
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Crear tablas necesarias
        await db.execute('''
          CREATE TABLE Administrador (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nombre TEXT NOT NULL,
            ApellidoPaterno TEXT NOT NULL,
            ApellidoMaterno TEXT NOT NULL,
            Correo TEXT NOT NULL UNIQUE,
            Contrasena TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Chef (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nombre TEXT NOT NULL,
            ApellidoPaterno TEXT NOT NULL,
            ApellidoMaterno TEXT NOT NULL,
            Correo TEXT NOT NULL UNIQUE,
            Contrasena TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Estudiante (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nombre TEXT NOT NULL,
            ApellidoPaterno TEXT NOT NULL,
            ApellidoMaterno TEXT NOT NULL,
            Correo TEXT NOT NULL UNIQUE,
            Contrasena TEXT NOT NULL,
            Matricula TEXT NOT NULL UNIQUE,
            Carrera TEXT NOT NULL,
            Semestre TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Docente (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nombre TEXT NOT NULL,
            ApellidoPaterno TEXT NOT NULL,
            ApellidoMaterno TEXT NOT NULL,
            Correo TEXT NOT NULL UNIQUE,
            Contrasena TEXT NOT NULL,
            RFC TEXT NOT NULL
          )
        ''');

        print("Tablas creadas exitosamente");
      },
      readOnly: false,
    );

    print("Conectado a la base de datos en: $path");
    return _database!;
  }

  static Future<Map<String, dynamic>?> loginUser(
      String correo, String contrasena, String rol) async {
    final db = await getDatabase();

    String tableName = '';
    String emailField = 'Correo';
    String passwordField = 'Contrasena';

    // Mapeo de roles a tablas
    switch (rol) {
      case 'Administrador':
        tableName = 'Administrador';
        break;
      case 'Chef':
        tableName = 'Chef';
        break;
      case 'Estudiante':
        tableName = 'Estudiante';
        break;
      case 'Docente':
        tableName = 'Docente';
        break;
      default:
        print("Rol no válido: $rol");
        return null;
    }

    try {
      print("=== Iniciando proceso de login ===");
      print("Tabla: $tableName");
      print("Correo proporcionado: $correo");
      print("Contraseña proporcionada: $contrasena");

      // Primero verificar si existe el correo
      final emailCheck = await db.query(
        tableName,
        where: '$emailField = ?',
        whereArgs: [correo],
      );

      if (emailCheck.isEmpty) {
        print("No se encontró el correo en la base de datos");
        return null;
      }

      print("Correo encontrado, verificando contraseña...");

      final result = await db.query(
        tableName,
        where: '$emailField = ? AND $passwordField = ?',
        whereArgs: [correo, contrasena],
      );

      if (result.isNotEmpty) {
        print("Login exitoso - Usuario encontrado:");
        print("Datos del usuario: ${result.first}");
        return result.first;
      } else {
        print("Contraseña incorrecta para el correo proporcionado");
      }
    } catch (e) {
      print("Error en consulta: $e");
      print("Stack trace: ${StackTrace.current}");
    }

    return null;
  }

  static Future<bool> checkEmailExists(String email, String rol) async {
    final db = await getDatabase();

    String tableName = '';
    String emailField = 'Correo';

    switch (rol) {
      case 'Chef':
        tableName = 'Chef';
        break;
      case 'Estudiante':
        tableName = 'Estudiante';
        break;
      case 'Docente':
        tableName = 'Docente';
        break;
      default:
        return false;
    }

    try {
      final result = await db.query(
        tableName,
        where: '$emailField = ?',
        whereArgs: [email],
      );

      return result.isNotEmpty;
    } catch (e) {
      print("Error al verificar correo: $e");
      return false;
    }
  }

  static Future<bool> registerChef(Map<String, dynamic> userData) async {
    final db = await getDatabase();

    try {
      print("Intentando registrar chef: ${userData.toString()}");

      bool exists = await checkEmailExists(userData['Correo'], 'Chef');
      if (exists) {
        print("El correo ya existe en la base de datos");
        return false;
      }

      int id = await db.insert('Chef', userData);
      print("Chef registrado con ID: $id");
      return id > 0;
    } catch (e) {
      print("Error al registrar chef: $e");
      print("Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  static Future<bool> registerEstudiante(Map<String, dynamic> userData) async {
    final db = await getDatabase();

    try {
      print("Intentando registrar estudiante: ${userData.toString()}");

      bool exists = await checkEmailExists(userData['Correo'], 'Estudiante');
      if (exists) {
        print("El correo ya existe en la base de datos");
        return false;
      }

      int id = await db.insert('Estudiante', userData);
      print("Estudiante registrado con ID: $id");
      return id > 0;
    } catch (e) {
      print("Error al registrar estudiante: $e");
      print("Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  static Future<bool> registerDocente(Map<String, dynamic> userData) async {
    final db = await getDatabase();

    try {
      print("Intentando registrar docente: ${userData.toString()}");

      bool exists = await checkEmailExists(userData['Correo'], 'Docente');
      if (exists) {
        print("El correo ya existe en la base de datos");
        return false;
      }

      int id = await db.insert('Docente', userData);
      print("Docente registrado con ID: $id");
      return id > 0;
    } catch (e) {
      print("Error al registrar docente: $e");
      print("Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  static Future<void> printDatabasePath() async {
    final dbPath = await getDatabasesPath();
    print("La base de datos se encuentra en: $dbPath");
  }
}
