import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidosRealizadosView extends StatelessWidget {
  const PedidosRealizadosView({super.key});

  Stream<QuerySnapshot> getPedidosRealizados() {
    return FirebaseFirestore.instance
        .collection('ordenes')
        .where('estado', isEqualTo: 'terminado')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [
            //HEADER
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
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(
                      Icons.arrow_back,
                      size: 34,
                      color: Colors.black,
                    ),
                  ),

                  const Text(
                    "Pedidos Realizados",

                    style: TextStyle(
                      fontSize: 32,
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
                stream: getPedidosRealizados(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),

                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay pedidos realizados",

                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final productos = List.from(data['productos'] ?? []);

                      final comentario = data['comentario'] ?? '';

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 8,
                        ),

                        padding: const EdgeInsets.all(18),

                        color: Colors.green.shade200,

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

                            //COMENTARIOS
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
                                      comentario.toString().isEmpty
                                          ? "Sin comentarios"
                                          : comentario,

                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //ESTADO
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 170,
                                    height: 55,

                                    decoration: BoxDecoration(
                                      color: Colors.green,

                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                    child: const Center(
                                      child: Text(
                                        "REALIZADO",

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
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
