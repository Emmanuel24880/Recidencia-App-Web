import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mesero.dart';

class MeserosController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 IMPORTANTE: colección correcta
  final String collection = 'mesero';

  Stream<List<Mesero>> obtenerMeseros() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Mesero.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> agregarMesero({
    required String nombre,
    required String telefono,
    required String contrasena,
    required String mesas,
  }) async {
    await _db.collection(collection).add({
      'nombre': nombre,
      'telefono': telefono,
      'contrasena': contrasena,
      'mesas': mesas,
      'estado': true,
      'fechaCreacion': DateTime.now(),
    });
  }

  Future<void> cambiarEstado(String id, bool estado) async {
    await _db.collection(collection).doc(id).update({'estado': estado});
  }

  Future<void> eliminarMesero(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}
