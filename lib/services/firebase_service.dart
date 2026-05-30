import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/producto.dart';
import '../models/administrador.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Productos
  Stream<List<Producto>> obtenerProductosActivos() {
    return _db
        .collection('productos')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Producto.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<DocumentReference> crearProducto(Producto producto) async {
    return await _db.collection('productos').add(producto.toMap());
  }

  // Administradores

  /// Crea un administrador en la colección "administradores".
  /// El ID del documento será el uid que pases en el modelo.
  Future<void> crearAdministrador(Administrador admin) async {
    await _db
        .collection('administradores')
        .doc(admin.uid) // uid = id del documento (el que usarás para login)
        .set(admin.toMap());
  }

  /// Obtiene un administrador por su uid (id del documento).
  Future<Administrador?> obtenerAdministradorPorUid(String uid) async {
    final doc = await _db.collection('administradores').doc(uid).get();

    if (!doc.exists) return null;

    return Administrador.fromMap(doc.id, doc.data()!);
  }

  /// Ejemplo: obtener todos los administradores activos
  Stream<List<Administrador>> obtenerAdministradoresActivos() {
    return _db
        .collection('administradores')
        .where('estado', isEqualTo: 'activo')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Administrador.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
