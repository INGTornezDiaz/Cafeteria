import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_database_structure.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseInitializer {
  final FirebaseDatabaseStructure db = FirebaseDatabaseStructure();
  final FirebaseService firebaseService = FirebaseService();

  Future<void> initializeDatabase() async {
    try {
      // 1. Crear roles
      await _createRoles();

      // 2. Intentar crear administrador inicial
      try {
        await _createInitialAdmin();
      } catch (e) {
        print('Advertencia: No se pudo crear el administrador inicial: $e');
        // Intentar verificar si el administrador ya existe
        try {
          final adminDoc = await db.getAdminByEmail('admin@comedor.com');
          if (adminDoc != null) {
            print('El administrador ya existe en la base de datos');
          }
        } catch (e) {
          print('Error verificando administrador existente: $e');
        }
      }

      // 3. Intentar crear chef inicial
      try {
        await _createInitialChef();
      } catch (e) {
        print('Advertencia: No se pudo crear el chef inicial: $e');
        // Intentar verificar si el chef ya existe
        try {
          final chefDoc = await db.getChefByEmail('chef@comedor.com');
          if (chefDoc != null) {
            print('El chef ya existe en la base de datos');
          }
        } catch (e) {
          print('Error verificando chef existente: $e');
        }
      }

      // 4. Crear menú inicial
      try {
        await _createInitialMenu();
      } catch (e) {
        print('Advertencia: No se pudo crear el menú inicial: $e');
      }

      print('Base de datos inicializada correctamente');
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  Future<void> _createRoles() async {
    try {
      // Crear roles básicos
      await db.createRol(id: 1, descripcion: 'Admin');
      await db.createRol(id: 2, descripcion: 'Chef');
      await db.createRol(id: 3, descripcion: 'Estudiante');
      await db.createRol(id: 4, descripcion: 'Docente');
      print('Roles creados correctamente');
    } catch (e) {
      print('Advertencia: Error al crear roles: $e');
      // Continuar incluso si hay error al crear roles
    }
  }

  Future<void> _createInitialAdmin() async {
    try {
      print('Iniciando creación del administrador...');

      // Verificar si el administrador ya existe en Authentication
      try {
        final adminUser = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail('admin@comedor.com');
        if (adminUser.isNotEmpty) {
          print('El administrador ya existe en Authentication');
          return;
        }
      } catch (e) {
        print('Error verificando administrador en Authentication: $e');
      }

      // Crear usuario en Authentication
      print('Creando usuario en Authentication...');
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'admin@comedor.com',
        password: 'admin123',
      );

      if (userCredential.user == null) {
        throw 'Error al crear el usuario administrador en Authentication';
      }

      final uid = userCredential.user!.uid;
      print('Usuario creado en Authentication con UID: $uid');

      // Crear documento en la colección de admins
      print('Creando documento en Firestore...');
      await FirebaseFirestore.instance.collection('admins').doc(uid).set({
        'ID_Admin': 1,
        'Usuario': 'admin@comedor.com',
        'Correo': 'admin@comedor.com',
        'Contrasena': 'admin123',
        'PK_ROL': 1,
      });

      print('Administrador inicial creado correctamente');
    } catch (e) {
      print('Error creando administrador inicial: $e');
      rethrow;
    }
  }

  Future<void> _createInitialChef() async {
    try {
      // Verificar si el chef ya existe
      final existingChef = await db.getChefByEmail('chef@comedor.com');
      if (existingChef != null) {
        print('El chef ya existe en la base de datos');
        return;
      }

      // Crear usuario en Authentication
      final userCredential =
          await firebaseService.createUserWithEmailAndPassword(
        'chef@comedor.com',
        'chef123',
      );

      if (userCredential?.user == null) {
        throw 'Error al crear el usuario chef';
      }

      // Agregar datos en Firestore
      await db.createChef(
        idChef: 1,
        nombre: 'Juan',
        apellidoP: 'Pérez',
        apellidoM: 'García',
        contrasena: 'chef123',
        correo: 'chef@comedor.com',
        telefono: '1234567890',
        pkRol: 2,
      );
      print('Chef inicial creado correctamente');
    } catch (e) {
      print('Error creando chef inicial: $e');
      rethrow;
    }
  }

  Future<void> _createInitialMenu() async {
    // Crear menú inicial
    await db.createMenu(
      idMenu: 1,
      platillos: 'Platillos del día',
      postres: 'Postres disponibles',
      bebida: 'Bebidas disponibles',
    );

    // Crear platillos de ejemplo
    await db.createPlatillo(
      idPlatillo: 1,
      nombre: 'Enchiladas Verdes',
      descripcion: 'Enchiladas verdes con pollo y crema',
      precio: 45.00,
      cantidad: 20,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/enchiladas.jpg',
    );

    await db.createPlatillo(
      idPlatillo: 2,
      nombre: 'Chilaquiles',
      descripcion: 'Chilaquiles con pollo y crema',
      precio: 40.00,
      cantidad: 15,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/chilaquiles.jpg',
    );

    // Crear postres de ejemplo
    await db.createPostre(
      idPostre: 1,
      tipos: 'Dulce',
      precio: 25.00,
      nombrePostre: 'Flan',
      cantidad: 10,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/flan.jpg',
    );

    await db.createPostre(
      idPostre: 2,
      tipos: 'Dulce',
      precio: 30.00,
      nombrePostre: 'Gelatina',
      cantidad: 15,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/gelatina.jpg',
    );

    // Crear bebidas de ejemplo
    await db.createBebida(
      idBebida: 1,
      tipoBebida: 'Refresco',
      cantidadMililitros: 500,
      precio: 15.00,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/refresco.jpg',
    );

    await db.createBebida(
      idBebida: 2,
      tipoBebida: 'Agua',
      cantidadMililitros: 600,
      precio: 10.00,
      pkMenu: 1,
      imagen: 'https://ejemplo.com/agua.jpg',
    );

    print('Menú inicial creado correctamente');
  }
}

// Función para ejecutar la inicialización
Future<void> initializeFirebaseDatabase() async {
  final initializer = DatabaseInitializer();
  await initializer.initializeDatabase();
}
