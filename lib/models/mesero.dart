class Mesero {
  final String id;
  final String nombre;
  final String telefono;
  final String contrasena;
  final String mesas;
  final bool estado;

  Mesero({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.contrasena,
    required this.mesas,
    required this.estado,
  });

  factory Mesero.fromMap(String id, Map<String, dynamic> data) {
    return Mesero(
      id: id,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      contrasena: data['contrasena'] ?? '',
      mesas: data['mesas'] ?? '',
      estado: data['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'contrasena': contrasena,
      'mesas': mesas,
      'estado': estado,
      'fechaCreacion': DateTime.now(),
    };
  }
}
