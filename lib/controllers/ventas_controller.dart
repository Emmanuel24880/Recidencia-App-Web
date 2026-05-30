import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orden.dart';

class VentasController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Orden>> obtenerVentasPorFecha(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('ordenes')
        .where('estado', isEqualTo: 'pagado')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('fecha', isLessThan: Timestamp.fromDate(fin))
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Orden.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<List<Orden>> obtenerVentasDelMes() async {
    final hoy = DateTime.now();

    final inicio = DateTime(hoy.year, hoy.month, 1);
    final fin = DateTime(hoy.year, hoy.month + 1, 1);

    final snapshot = await _db
        .collection('ordenes')
        .where('estado', isEqualTo: 'pagado')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('fecha', isLessThan: Timestamp.fromDate(fin))
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Orden.fromMap(doc.id, doc.data());
    }).toList();
  }
}
