// lib/views/screens/cocinero_home.dart

import 'dart:developer';

import 'package:app_web_1/views/screens/pedidos_realizados_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CocineroHome extends StatelessWidget {
  final Map<String, dynamic> cocinero;

  const CocineroHome({super.key, required this.cocinero});

  Stream<QuerySnapshot> getOrdenes() {
    try {
      return FirebaseFirestore.instance
          .collection('ordenes')
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('fecha', descending: false)
          .snapshots();
    } catch (e) {
      log("ERROR FIREBASE:");
      log(e.toString());

      rethrow;
    }
  }

  Future<void> cambiarEstado(String docId) async {
    /// 🔥 CAMBIA A LISTO
    await FirebaseFirestore.instance.collection('ordenes').doc(docId).update({
      "estadoCocina": "listo",
    });

    /// 🔥 ESPERA 2 SEGUNDOS
    await Future.delayed(const Duration(seconds: 2));

    /// 🔥 CAMBIA ESTADO GENERAL
    await FirebaseFirestore.instance.collection('ordenes').doc(docId).update({
      "estado": "terminado",
    });
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'preparando':
        return Colors.orange.shade200;

      case 'listo':
        return Colors.green.shade200;

      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 24),

              decoration: const BoxDecoration(
                color: Color(0xFFF4B400),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  PopupMenuButton(
                    icon: const Icon(Icons.menu, size: 34, color: Colors.black),

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'realizados',
                        child: Text("Pedidos realizados"),
                      ),
                    ],

                    onSelected: (value) {
                      if (value == 'realizados') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PedidosRealizadosView(),
                          ),
                        );
                      }
                    },
                  ),
                  const Text(
                    "Ordenes Del Día",

                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  Container(
                    width: 55,
                    height: 55,

                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),

                    child: const Icon(Icons.restaurant, color: Colors.amber),
                  ),
                ],
              ),
            ),

            //LISTA
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getOrdenes(),

                builder: (context, snapshot) {
                  //ERROR FIREBASE
                  if (snapshot.hasError) {
                    debugPrint("FIREBASE ERROR: ${snapshot.error}");

                    return Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),

                          child: Text(
                            snapshot.error.toString(),

                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  //LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }

                  //SIN DATOS
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        "Sin datos",

                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  //SIN PEDIDOS
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay pedidos",

                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final productos = List.from(data['productos'] ?? []);

                      final estadoCocina = data['estadoCocina'] ?? 'pendiente';

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 8,
                        ),

                        padding: const EdgeInsets.all(18),

                        color: colorEstado(estadoCocina),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            //MESA
                            SizedBox(
                              width: 120,

                              child: Center(
                                child: Text(
                                  "Mesa ${data['mesa']}",

                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 220,
                              color: Colors.black45,
                            ),

                            const SizedBox(width: 25),

                            //PEDIDOS
                            Expanded(
                              flex: 2,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Pedido",

                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  ...productos.map((p) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),

                                      child: Text(
                                        "--${p['nombre']}",

                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            //CANTIDAD
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  const Text(
                                    "Cantidad",

                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  ...productos.map((p) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),

                                      child: Text(
                                        "${p['cantidad']}",

                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            /// 🔥 COMENTARIOS
                            Expanded(
                              flex: 2,

                              child: Column(
                                children: [
                                  const Text(
                                    "Comentarios",

                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    width: 280,
                                    height: 130,

                                    padding: const EdgeInsets.all(14),

                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Text(
                                      (data['comentario'] ?? '')
                                              .toString()
                                              .isEmpty
                                          ? "Sin comentarios"
                                          : data['comentario'],

                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// 🔥 BOTÓN
                            Expanded(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await cambiarEstado(doc.id);
                                    },

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: estadoCocina == 'listo'
                                          ? Colors.green
                                          : Colors.orange,

                                      minimumSize: const Size(160, 50),
                                    ),

                                    child: Text(
                                      estadoCocina == 'listo'
                                          ? "LISTO"
                                          : "POR HACER",

                                      style: TextStyle(
                                        color: estadoCocina == 'listo'
                                            ? Colors.white
                                            : Colors.black,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
