import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String imagenUrl;
  final String categoria;
  final double precio;
  final bool activo;
  final int stock;
  final String descripcion;
  final DateTime creadoEn;

  Producto({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.categoria,
    required this.precio,
    required this.activo,
    this.stock = 0,
    this.descripcion = '',
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      categoria: map['categoria'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      activo: map['activo'] ?? false,
      stock: map['stock'] ?? 0,
      descripcion: map['descripcion'] ?? '',
      creadoEn: (map['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'precio': precio,
      'activo': activo,
      'stock': stock,
      'descripcion': descripcion,
      'creadoEn': Timestamp.fromDate(creadoEn),
    };
  }

  Producto copyWith({
    String? id,
    String? nombre,
    double? precio,
    String? categoria,
    String? descripcion,
    String? imagenUrl,
    bool? activo,
    int? stock,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      activo: activo ?? this.activo,
      stock: stock ?? this.stock,
    );
  }
}
