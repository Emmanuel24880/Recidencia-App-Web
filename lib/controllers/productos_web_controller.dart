import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class ProductosWebController {
  Stream<List<Producto>> streamProductosActivos() {
    return FirebaseFirestore.instance
        .collection('producto')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Producto.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Producto>> streamTodosLosProductos() {
    return FirebaseFirestore.instance.collection('producto').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Producto.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  List<Producto> filtrarPorCategoria(
    List<Producto> productos,
    String categoria,
  ) {
    if (categoria == 'Todos') return productos;
    return productos.where((p) => p.categoria == categoria).toList();
  }

  Future<bool> crearProducto(Producto producto) async {
    try {
      print('Creando con set(): ${producto.nombre}');
      final docRef = FirebaseFirestore.instance
          .collection('producto')
          .doc(); // ID manual
      await docRef
          .set({...producto.toMap(), 'id': docRef.id}, SetOptions(merge: true))
          .timeout(const Duration(seconds: 30)); // +20s para cold start
      print('¡DOC ${docRef.id} CREADO!');
      return true;
    } catch (e) {
      print('ERROR: $e');
      return false;
    }
  }

  Future<bool> actualizarProducto(Producto producto) async {
    try {
      await FirebaseFirestore.instance
          .collection('producto')
          .doc(producto.id)
          .update(producto.toMap());

      return true;
    } catch (e) {
      print("Error actualizando: $e");
      return false;
    }
  }

  Future<void> eliminarProducto(String id) async {
    await FirebaseFirestore.instance.collection('producto').doc(id).delete();
  }
}
