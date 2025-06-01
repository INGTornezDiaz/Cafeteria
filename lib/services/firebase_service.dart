import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticación
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error en inicio de sesión: $e');
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      // Validar formato de email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw 'El formato del correo electrónico no es válido';
      }

      // Validar contraseña
      if (password.length < 6) {
        throw 'La contraseña debe tener al menos 6 caracteres';
      }

      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Operaciones CRUD para usuarios
  Future<bool> registerEstudiante(Map<String, dynamic> userData) async {
    try {
      // Crear usuario en Authentication
      final userCredential = await createUserWithEmailAndPassword(
        userData['Correo'],
        userData['Contrasena'],
      );

      if (userCredential?.user == null) {
        throw 'Error al crear el usuario';
      }

      // Agregar datos adicionales en Firestore
      await _firestore
          .collection('estudiantes')
          .doc(userCredential?.user?.uid)
          .set({
        'ID_No_Control': userData['matricula'],
        'Nombre': userData['Nombre'],
        'ApellidoP': userData['ApellidoPaterno'],
        'ApellidoM': userData['ApellidoMaterno'],
        'Correo': userData['Correo'],
        'Telefono': userData['Telefono'],
        'Carrera': userData['Carrera'],
        'Semestre': userData['Semestre'],
        'PK_ROL': 3,
      });
      return true;
    } catch (e) {
      print('Error registrando estudiante: $e');
      rethrow;
    }
  }

  Future<bool> registerDocente(Map<String, dynamic> userData) async {
    try {
      final userCredential = await createUserWithEmailAndPassword(
        userData['Correo'],
        userData['Contrasena'],
      );

      if (userCredential?.user == null) {
        throw 'Error al crear el usuario';
      }

      await _firestore
          .collection('docentes')
          .doc(userCredential?.user?.uid)
          .set({
        'ID_RFC': userData['RFC'],
        'Nombre': userData['Nombre'],
        'ApellidoP': userData['ApellidoPaterno'],
        'ApellidoM': userData['ApellidoMaterno'],
        'Correo': userData['Correo'],
        'Telefono': userData['Telefono'],
        'PK_ROL': 4,
      });
      return true;
    } catch (e) {
      print('Error registrando docente: $e');
      rethrow;
    }
  }

  Future<bool> registerChef(Map<String, dynamic> userData) async {
    try {
      final userCredential = await createUserWithEmailAndPassword(
        userData['Correo'],
        userData['Contrasena'],
      );

      if (userCredential?.user == null) {
        throw 'Error al crear el usuario';
      }

      await _firestore.collection('chefs').doc(userCredential?.user?.uid).set({
        'Nombre': userData['Nombre'],
        'ApellidoP': userData['ApellidoPaterno'],
        'ApellidoM': userData['ApellidoMaterno'],
        'Correo': userData['Correo'],
        'PK_ROL': 2,
      });
      return true;
    } catch (e) {
      print('Error registrando chef: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(
      String email, String password, String rol) async {
    try {
      print('Intentando iniciar sesión con: $email y rol: $rol');

      // Intentar iniciar sesión con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential == null || userCredential.user == null) {
        print('Error: Credenciales inválidas');
        return null;
      }

      // Obtener el UID del usuario
      final uid = userCredential.user!.uid;
      print('Usuario autenticado con UID: $uid');

      // Buscar el documento del usuario en la colección correspondiente
      String collection = '';
      switch (rol) {
        case 'Estudiante':
          collection = 'estudiantes';
          break;
        case 'Docente':
          collection = 'docentes';
          break;
        case 'Chef':
          collection = 'chefs';
          break;
        case 'Admin':
          collection = 'admins';
          break;
        default:
          print('Error: Rol no válido: $rol');
          return null;
      }

      print('Buscando usuario en colección: $collection');

      // Buscar el documento del usuario
      final doc = await _firestore.collection(collection).doc(uid).get();

      if (!doc.exists) {
        print('Error: No se encontró el documento del usuario en $collection');
        // Intentar buscar por email como alternativa
        final querySnapshot = await _firestore
            .collection(collection)
            .where('Correo', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isEmpty) {
          print('Error: No se encontró el usuario por email en $collection');
          return null;
        }

        print('Usuario encontrado por email');
        return querySnapshot.docs.first.data();
      }

      print('Usuario encontrado en Firestore');
      return doc.data();
    } on FirebaseAuthException catch (e) {
      print('Error de Firebase Auth: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        print('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta');
      } else if (e.code == 'invalid-credential') {
        print('Credenciales inválidas');
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers(String rol) async {
    try {
      String collection = '';
      switch (rol) {
        case 'Estudiante':
          collection = 'estudiantes';
          break;
        case 'Docente':
          collection = 'docentes';
          break;
        case 'Chef':
          collection = 'chefs';
          break;
      }

      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteUser(String role, String id) async {
    try {
      final collection = _firestore.collection(role.toLowerCase() + 's');
      final querySnapshot = await collection
          .where(
              role == 'Estudiante'
                  ? 'ID_No_Control'
                  : role == 'Docente'
                      ? 'ID_RFC'
                      : 'ID_Chef',
              isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      print('Error eliminando usuario: $e');
      rethrow;
    }
  }
}
