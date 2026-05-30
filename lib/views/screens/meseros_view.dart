import 'package:flutter/material.dart';
import '../../controllers/meseros_controller.dart';
import '../../models/mesero.dart';

class MeserosView extends StatefulWidget {
  const MeserosView({super.key});

  @override
  State<MeserosView> createState() => _MeserosViewState();
}

class _MeserosViewState extends State<MeserosView> {
  final MeserosController _controller = MeserosController();

  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final contrasenaController = TextEditingController();
  final mesasController = TextEditingController();

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo Mesero"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
              TextField(
                controller: contrasenaController,
                decoration: const InputDecoration(labelText: "Contraseña"),
              ),
              TextField(
                controller: mesasController,
                decoration: const InputDecoration(labelText: "Mesas"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.agregarMesero(
                nombre: nombreController.text,
                telefono: telefonoController.text,
                contrasena: contrasenaController.text,
                mesas: mesasController.text,
              );

              nombreController.clear();
              telefonoController.clear();
              contrasenaController.clear();
              mesasController.clear();

              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  bool mostrarActivos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administrador de Meseros"),
        backgroundColor: const Color(0xFFF4B400),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          /// 🔥 FILTRO
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() => mostrarActivos = true);
                },
                child: const Text("Activos"),
              ),
              TextButton(
                onPressed: () {
                  setState(() => mostrarActivos = false);
                },
                child: const Text("Inactivos"),
              ),
            ],
          ),

          Expanded(
            child: StreamBuilder<List<Mesero>>(
              stream: _controller.obtenerMeseros(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meseros = snapshot.data!
                    .where(
                      (m) =>
                          mostrarActivos ? m.estado == true : m.estado == false,
                    )
                    .toList();

                if (meseros.isEmpty) {
                  return const Center(child: Text("Sin meseros"));
                }

                return ListView.builder(
                  itemCount: meseros.length,
                  itemBuilder: (context, index) {
                    final m = meseros[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(m.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tel: ${m.telefono}"),
                            Text("Mesas: ${m.mesas}"),
                            Text(m.estado ? "Activo" : "Inactivo"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: m.estado,
                              onChanged: (value) {
                                _controller.cambiarEstado(m.id, value);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _controller.eliminarMesero(m.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
