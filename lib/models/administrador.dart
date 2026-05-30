// lib/models/administrador.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Administrador {
  final String uid; // id del documento en Firestore
  final String nombreCompleto;
  final String telefono;
  final String estado;
  final String contrasena; // campo "contraseña" en Firestore
  final Timestamp? fechaCreacion;

  Administrador({
    required this.uid,
    required this.nombreCompleto,
    required this.telefono,
    required this.estado,
    required this.contrasena,
    this.fechaCreacion,
  });

  factory Administrador.fromMap(String uid, Map<String, dynamic> map) {
    return Administrador(
      uid: uid,
      nombreCompleto: map['nombreCompleto'] ?? '',
      telefono: map['telefono'] ?? '',
      estado: map['estado'] ?? '',
      contrasena: map['contraseña'] ?? '',
      fechaCreacion: map['fechaCreacion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'estado': estado,
      'contraseña': contrasena,
      'fechaCreacion': fechaCreacion,
    };
  }
}
