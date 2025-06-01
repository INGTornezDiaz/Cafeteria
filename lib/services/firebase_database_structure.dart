import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseStructure {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencias a colecciones
  CollectionReference get roles => _firestore.collection('roles');
  CollectionReference get estudiantes => _firestore.collection('estudiantes');
  CollectionReference get docentes => _firestore.collection('docentes');
  CollectionReference get chefs => _firestore.collection('chefs');
  CollectionReference get admins => _firestore.collection('admins');
  CollectionReference get menu => _firestore.collection('menu');
  CollectionReference get platillos => _firestore.collection('platillos');
  CollectionReference get postres => _firestore.collection('postres');
  CollectionReference get bebidas => _firestore.collection('bebidas');
  CollectionReference get ordenes => _firestore.collection('ordenes');
  CollectionReference get reportesDia => _firestore.collection('reportesDia');
  CollectionReference get reportesGeneral =>
      _firestore.collection('reportesGeneral');

  // Estructura de datos para roles
  Future<void> createRol({
    required int id,
    required String descripcion,
  }) async {
    await roles.doc(id.toString()).set({
      'ID': id,
      'Descripcion': descripcion,
    });
  }

  // Estructura de datos para admins
  Future<void> createAdmin({
    required int idAdmin,
    required String usuario,
    required String contrasena,
    required int pkRol,
  }) async {
    await admins.doc(idAdmin.toString()).set({
      'ID_Admin': idAdmin,
      'Usuario': usuario,
      'Contrasena': contrasena,
      'PK_ROL': pkRol,
    });
  }

  // Estructura de datos para estudiantes
  Future<void> createEstudiante({
    required int idNoControl,
    required String nombre,
    required String apellidoP,
    required String apellidoM,
    required String correo,
    required int telefono,
    required String contrasena,
    required String carrera,
    required int semestre,
    required int pkRol,
  }) async {
    await estudiantes.doc(idNoControl.toString()).set({
      'ID_No_Control': idNoControl,
      'Nombre': nombre,
      'ApellidoP': apellidoP,
      'ApellidoM': apellidoM,
      'Correo': correo,
      'Telefono': telefono,
      'Contrasena': contrasena,
      'Carrera': carrera,
      'Semestre': semestre,
      'PK_ROL': pkRol,
    });
  }

  // Estructura de datos para docentes
  Future<void> createDocente({
    required String idRfc,
    required String nombre,
    required String apellidoP,
    required String apellidoM,
    required String correo,
    required int telefono,
    required String contrasena,
    required int pkRol,
  }) async {
    await docentes.doc(idRfc).set({
      'ID_RFC': idRfc,
      'Nombre': nombre,
      'ApellidoP': apellidoP,
      'ApellidoM': apellidoM,
      'Correo': correo,
      'Telefono': telefono,
      'Contrasena': contrasena,
      'PK_ROL': pkRol,
    });
  }

  // Estructura de datos para chefs
  Future<void> createChef({
    required int idChef,
    required String nombre,
    required String apellidoP,
    required String apellidoM,
    required String contrasena,
    required String correo,
    required String telefono,
    required int pkRol,
  }) async {
    await chefs.doc(idChef.toString()).set({
      'ID_Chef': idChef,
      'Nombre': nombre,
      'ApellidoP': apellidoP,
      'ApellidoM': apellidoM,
      'Contrasena': contrasena,
      'Correo': correo,
      'Telefono': telefono,
      'PK_ROL': pkRol,
    });
  }

  // Estructura de datos para menú
  Future<void> createMenu({
    required int idMenu,
    required String platillos,
    required String postres,
    required String bebida,
  }) async {
    await menu.doc(idMenu.toString()).set({
      'ID_Menu': idMenu,
      'Platillos': platillos,
      'Postres': postres,
      'Bebida': bebida,
    });
  }

  // Estructura de datos para platillos
  Future<void> createPlatillo({
    required int idPlatillo,
    required String nombre,
    required String descripcion,
    required double precio,
    required int cantidad,
    required int pkMenu,
    required String imagen,
  }) async {
    await platillos.doc(idPlatillo.toString()).set({
      'ID_platillo': idPlatillo,
      'Nombre': nombre,
      'Descripcion': descripcion,
      'Precio': precio,
      'Cantidad': cantidad,
      'PK_Menu': pkMenu,
      'Imagen': imagen,
    });
  }

  // Estructura de datos para postres
  Future<void> createPostre({
    required int idPostre,
    required String tipos,
    required double precio,
    required String nombrePostre,
    required int cantidad,
    required int pkMenu,
    required String imagen,
  }) async {
    await postres.doc(idPostre.toString()).set({
      'ID_postre': idPostre,
      'Tipos': tipos,
      'Precio': precio,
      'Nombre_postre': nombrePostre,
      'Cantidad': cantidad,
      'PK_Menu': pkMenu,
      'Imagen': imagen,
    });
  }

  // Estructura de datos para bebidas
  Future<void> createBebida({
    required int idBebida,
    required String tipoBebida,
    required int cantidadMililitros,
    required double precio,
    required int pkMenu,
    required String imagen,
  }) async {
    await bebidas.doc(idBebida.toString()).set({
      'ID_bebida': idBebida,
      'Tipo_bebida': tipoBebida,
      'CantidadMililitros': cantidadMililitros,
      'Precio': precio,
      'PK_Menu': pkMenu,
      'Imagen': imagen,
    });
  }

  // Estructura de datos para órdenes
  Future<void> createOrden({
    required int idOrden,
    required DateTime fecha,
    required String hora,
    required String platillo,
    required String bebidas,
    required String postre,
    required int cantidad,
    required double precio,
    required double total,
    required String comentarios,
    required String status,
    String? pkDocente,
    int? pkEstudiante,
  }) async {
    await ordenes.doc(idOrden.toString()).set({
      'ID_Orden': idOrden,
      'Fecha': fecha,
      'Hora': hora,
      'Platillo': platillo,
      'Bebidas': bebidas,
      'Postre': postre,
      'Cantidad': cantidad,
      'Precio': precio,
      'Total': total,
      'Comentarios': comentarios,
      'status': status,
      'PK_Docente': pkDocente,
      'PK_Estudiante': pkEstudiante,
    });
  }

  // Estructura de datos para reportes diarios
  Future<void> createReporteDia({
    required int idReporte,
    required DateTime fecha,
    required double total,
    required String platillo,
    required String bebida,
    required String postre,
    required int cantidad,
    required int pkOrden,
  }) async {
    await reportesDia.doc(idReporte.toString()).set({
      'ID_Reporte': idReporte,
      'Fecha': fecha,
      'Total': total,
      'Platillo': platillo,
      'Bebida': bebida,
      'Postre': postre,
      'Cantidad': cantidad,
      'PK_Orden': pkOrden,
    });
  }

  // Estructura de datos para reportes generales
  Future<void> createReporteGeneral({
    required int idReporte,
    required DateTime fecha,
    required String tipoReporte,
    required double total,
    required double totalPlatillo,
    required int cantidad,
    required int pkReporteDia,
  }) async {
    await reportesGeneral.doc(idReporte.toString()).set({
      'ID_Reporte': idReporte,
      'Fecha': fecha,
      'Tipo_Reporte': tipoReporte,
      'Total': total,
      'Total_Platillo': totalPlatillo,
      'Cantidad': cantidad,
      'PK_ReporteDia': pkReporteDia,
    });
  }

  // Métodos de consulta
  Future<DocumentSnapshot> getRol(int id) async {
    return await roles.doc(id.toString()).get();
  }

  Future<DocumentSnapshot> getEstudiante(int idNoControl) async {
    return await estudiantes.doc(idNoControl.toString()).get();
  }

  Future<DocumentSnapshot> getDocente(String idRfc) async {
    return await docentes.doc(idRfc).get();
  }

  Future<DocumentSnapshot> getChef(int idChef) async {
    return await chefs.doc(idChef.toString()).get();
  }

  Future<DocumentSnapshot> getMenu(int idMenu) async {
    return await menu.doc(idMenu.toString()).get();
  }

  Future<QuerySnapshot> getPlatillosPorMenu(int pkMenu) async {
    return await platillos.where('PK_Menu', isEqualTo: pkMenu).get();
  }

  Future<QuerySnapshot> getPostresPorMenu(int pkMenu) async {
    return await postres.where('PK_Menu', isEqualTo: pkMenu).get();
  }

  Future<QuerySnapshot> getBebidasPorMenu(int pkMenu) async {
    return await bebidas.where('PK_Menu', isEqualTo: pkMenu).get();
  }

  Future<QuerySnapshot> getOrdenesPorFecha(DateTime fecha) async {
    return await ordenes.where('Fecha', isEqualTo: fecha).get();
  }

  Future<QuerySnapshot> getReportesDiaPorFecha(DateTime fecha) async {
    return await reportesDia.where('Fecha', isEqualTo: fecha).get();
  }

  Future<QuerySnapshot> getReportesGeneralPorTipo(String tipoReporte) async {
    return await reportesGeneral
        .where('Tipo_Reporte', isEqualTo: tipoReporte)
        .get();
  }

  Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('admins')
          .where('usuario', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error obteniendo admin por email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getChefByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('chefs')
          .where('correo', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error obteniendo chef por email: $e');
      return null;
    }
  }
}

void crearDatosIniciales() async {
  final db = FirebaseDatabaseStructure();

  // Crear roles
  await db.createRol(id: 1, descripcion: 'Admin');
  await db.createRol(id: 2, descripcion: 'Chef');
  await db.createRol(id: 3, descripcion: 'Estudiante');
  await db.createRol(id: 4, descripcion: 'Docente');

  // Crear un admin
  await db.createAdmin(
    idAdmin: 1,
    usuario: 'admin',
    contrasena: 'admin123',
    pkRol: 1,
  );

  // Crear un chef
  await db.createChef(
    idChef: 1,
    nombre: 'Juan',
    apellidoP: 'Pérez',
    apellidoM: 'García',
    contrasena: 'chef123',
    correo: 'juan.chef@ejemplo.com',
    telefono: '1234567890',
    pkRol: 2,
  );

  // Crear un menú
  await db.createMenu(
    idMenu: 1,
    platillos: 'Platillos del día',
    postres: 'Postres disponibles',
    bebida: 'Bebidas disponibles',
  );
}
