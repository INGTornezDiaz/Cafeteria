import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App3DTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF00FF9D);
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  static const Color accentColor = Color(0xFFFF00FF);

  // Efectos de neón
  static List<BoxShadow> neonShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 4,
        ),
      ];

  // Efectos de cristal
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  // Estilos de texto
  static TextStyle get titleStyle => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      );

  static TextStyle get subtitleStyle => TextStyle(
        fontSize: 16,
        color: Colors.white70,
        letterSpacing: 0.5,
      );

  // Estilos de botones
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 8,
    shadowColor: primaryColor.withOpacity(0.5),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
      );

  // Estilos de tarjetas
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  // Estilos de campos de texto
  static final InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: primaryColor,
        width: 2,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  // Sombras y efectos 3D
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          blurRadius: 1,
          offset: Offset(0, -1),
        ),
      ];

  // Efectos de hover y presión
  static BoxDecoration get hoverEffect => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      );

  // Animaciones
  static Duration get animationDuration => Duration(milliseconds: 300);
  static Curve get animationCurve => Curves.easeInOut;

  // Configuración del sistema
  static SystemUiOverlayStyle get systemOverlayStyle => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      );
}
