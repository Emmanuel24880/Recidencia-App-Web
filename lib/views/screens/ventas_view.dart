import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../controllers/ventas_controller.dart';
import '../../models/orden.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;

class VentasView extends StatefulWidget {
  const VentasView({super.key});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  final VentasController controller = VentasController();

  late Future<List<Orden>> ventasFuture;
  DateTime fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    ventasFuture = controller.obtenerVentasPorFecha(fechaSeleccionada);
  }

  Future<void> exportarExcel() async {
    try {
      final ventas = await controller.obtenerVentasDelMes();

      print("TOTAL VENTAS:");
      print(ventas.length);

      var excel = Excel.createExcel();
      Sheet sheet = excel['Ventas'];

      // ENCABEZADOS
      sheet.appendRow([
        TextCellValue("Mesero"),
        TextCellValue("Mesa"),
        TextCellValue("Producto"),
        TextCellValue("Precio"),
        TextCellValue("Total"),
        TextCellValue("Fecha"),
      ]);

      for (var orden in ventas) {
        print("==============");
        print("ORDEN:");
        print(orden);

        print("PRODUCTOS:");
        print(orden.productos);

        for (var p in orden.productos) {
          print("PRODUCTO INDIVIDUAL:");
          print(p);

          final mesero = orden.meseroNombre.toString();
          final mesa = orden.mesa.toString();

          final producto = p['nombre'].toString();

          final precio = p['precio'].toString();

          final total = orden.total.toString();

          final fecha = orden.fecha.toString();

          print(mesero);
          print(mesa);
          print(producto);
          print(precio);

          sheet.appendRow([
            TextCellValue(mesero),
            IntCellValue(int.tryParse(mesa) ?? 0),
            TextCellValue(producto),
            DoubleCellValue(double.tryParse(precio) ?? 0),
            DoubleCellValue(double.tryParse(total) ?? 0),
            TextCellValue(fecha),
          ]);
        }
      }

      final bytes = excel.encode();

      if (bytes == null) {
        print("BYTES NULL");
        return;
      }

      final blob = html.Blob([Uint8List.fromList(bytes)]);

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "ventas_mes.xlsx")
        ..click();

      html.Url.revokeObjectUrl(url);

      print("EXCEL DESCARGADO");
    } catch (e) {
      print("ERROR EXPORTAR EXCEL:");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas del día"),
        backgroundColor: const Color(0xFFF4B400),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Descargar Excel",
            onPressed: () async {
              await exportarExcel();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔥 SELECTOR DE FECHA
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        fechaSeleccionada = pickedDate;
                        ventasFuture = controller.obtenerVentasPorFecha(
                          pickedDate,
                        );
                      });
                    }
                  },
                  child: const Text("Seleccionar fecha"),
                ),
              ],
            ),
          ),

          //CONTENIDO
          Expanded(
            child: FutureBuilder<List<Orden>>(
              future: ventasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return SingleChildScrollView(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay ventas en este día"));
                }

                final ordenes = snapshot.data!;

                // AGRUPAR POR MESERO
                final Map<String, List<Orden>> ventasPorMesero = {};

                for (var orden in ordenes) {
                  if (!ventasPorMesero.containsKey(orden.meseroNombre)) {
                    ventasPorMesero[orden.meseroNombre] = [];
                  }
                  ventasPorMesero[orden.meseroNombre]!.add(orden);
                }

                return Row(
                  children: [
                    // MESEROS
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: const Color(0xFFD4A64A),
                        child: ListView(
                          children: ventasPorMesero.keys.map((mesero) {
                            final mesas = ventasPorMesero[mesero]!
                                .map((o) => o.mesa)
                                .toSet()
                                .join(", ");

                            final totalMesero = ventasPorMesero[mesero]!.fold(
                              0.0,
                              (sum, o) => sum + o.total,
                            );

                            return ListTile(
                              title: Text(
                                mesero,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Mesas: $mesas\nTotal: \$${totalMesero.toStringAsFixed(0)}",
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // ÓRDENES
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: ordenes.length,
                        itemBuilder: (context, index) {
                          final o = ordenes[index];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                /// MESA
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    o.mesa.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                /// PRODUCTOS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...o.productos.map((p) {
                                        return Text(
                                          "${p['nombre']} : \$${p['precio']}",
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                /// TOTAL Y ESTADO
                                Column(
                                  children: [
                                    Text("Total \$${o.total}"),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: o.estado == "pagado"
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        o.estado,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
