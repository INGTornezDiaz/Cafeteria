import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _uuid = Uuid();

  Future<String> savePlatilloImage(File imageFile) async {
    try {
      // Obtener la extensión del archivo
      final String extension = path.extension(imageFile.path);

      // Generar un nombre único para la imagen
      final String fileName = '${_uuid.v4()}$extension';

      // Obtener el directorio de documentos
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String platillosDir = path.join(appDir.path, 'platillos');

      // Crear el directorio si no existe
      await Directory(platillosDir).create(recursive: true);

      // Ruta completa del archivo
      final String filePath = path.join(platillosDir, fileName);

      // Copiar el archivo al directorio de la aplicación
      await imageFile.copy(filePath);

      return fileName;
    } catch (e) {
      print('Error al guardar la imagen: $e');
      throw Exception('No se pudo guardar la imagen: $e');
    }
  }

  Future<String> savePostreImage(File imageFile) async {
    try {
      final String extension = path.extension(imageFile.path);
      final String fileName = '${_uuid.v4()}$extension';

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String postresDir = path.join(appDir.path, 'postres');

      await Directory(postresDir).create(recursive: true);
      final String filePath = path.join(postresDir, fileName);

      await imageFile.copy(filePath);
      return fileName;
    } catch (e) {
      print('Error al guardar la imagen: $e');
      throw Exception('No se pudo guardar la imagen: $e');
    }
  }

  Future<String> saveBebidaImage(File imageFile) async {
    try {
      final String extension = path.extension(imageFile.path);
      final String fileName = '${_uuid.v4()}$extension';

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String bebidasDir = path.join(appDir.path, 'bebidas');

      await Directory(bebidasDir).create(recursive: true);
      final String filePath = path.join(bebidasDir, fileName);

      await imageFile.copy(filePath);
      return fileName;
    } catch (e) {
      print('Error al guardar la imagen: $e');
      throw Exception('No se pudo guardar la imagen: $e');
    }
  }

  Future<String> savePerfilImage(File imageFile, String userId) async {
    try {
      final String extension = path.extension(imageFile.path);
      final String fileName = '${_uuid.v4()}$extension';

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String perfilesDir = path.join(appDir.path, 'perfiles', userId);

      await Directory(perfilesDir).create(recursive: true);
      final String filePath = path.join(perfilesDir, fileName);

      await imageFile.copy(filePath);
      return fileName;
    } catch (e) {
      print('Error al guardar la imagen: $e');
      throw Exception('No se pudo guardar la imagen: $e');
    }
  }

  Future<File?> getImageFile(String fileName, String type) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, type, fileName);
      final File file = File(filePath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error al obtener la imagen: $e');
      return null;
    }
  }

  Future<void> deleteImage(String fileName, String type) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, type, fileName);
      final File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error al eliminar la imagen: $e');
      throw Exception('No se pudo eliminar la imagen: $e');
    }
  }
}
