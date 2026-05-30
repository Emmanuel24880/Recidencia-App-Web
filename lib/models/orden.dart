import 'package:cloud_firestore/cloud_firestore.dart';

class Orden {
  final String id;
  final String meseroNombre;
  final String mesa;
  final List<dynamic> productos;
  final double total;
  final String estado;
  final DateTime fecha;

  Orden({
    required this.id,
    required this.meseroNombre,
    required this.mesa,
    required this.productos,
    required this.total,
    required this.estado,
    required this.fecha,
  });

  factory Orden.fromMap(String id, Map<String, dynamic> data) {
    return Orden(
      id: id,

      meseroNombre: data['meseroNombre']?.toString() ?? '',

      mesa: data['mesa']?.toString() ?? '',

      productos: List<dynamic>.from(data['productos'] ?? []),

      total: (data['total'] ?? 0).toDouble(),

      estado: data['estado']?.toString() ?? '',

      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }
}
