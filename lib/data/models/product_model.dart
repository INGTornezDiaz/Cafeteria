class ProductModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;
  final String categoria;
  final int cantidad;
  final String? notas;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.categoria,
    this.cantidad = 1,
    this.notas,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] is num) ? map['precio'].toDouble() : 0.0,
      imagen: map['imagen'] ?? '',
      categoria: map['categoria'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      notas: map['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'cantidad': cantidad,
      'notas': notas,
    };
  }

  ProductModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagen,
    String? categoria,
    int? cantidad,
    String? notas,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      notas: notas ?? this.notas,
    );
  }
}
