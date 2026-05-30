import 'package:flutter/material.dart';
import '../../controllers/productos_web_controller.dart';
import '../../models/producto.dart';

class EditProductView extends StatefulWidget {
  final Producto producto;

  const EditProductView({super.key, required this.producto});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProductosWebController();

  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imagePathCtrl;

  String _categoria = 'Desayuno';
  String _imagePath = '';
  bool _isSaving = false;
  bool _activo = true;

  @override
  void initState() {
    super.initState();

    final p = widget.producto;

    _nombreCtrl = TextEditingController(text: p.nombre);
    _precioCtrl = TextEditingController(text: p.precio.toString());
    _descripcionCtrl = TextEditingController(text: p.descripcion);
    _stockCtrl = TextEditingController(text: p.stock.toString());
    _imagePathCtrl = TextEditingController(text: p.imagenUrl);

    _categoria = p.categoria;
    _imagePath = p.imagenUrl;
    _activo = p.activo;
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final producto = Producto(
      id: widget.producto.id, // IMPORTANTE
      nombre: _nombreCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      categoria: _categoria,
      descripcion: _descripcionCtrl.text.trim(),
      imagenUrl: _imagePath,
      activo: _activo,
      stock: int.parse(_stockCtrl.text.trim()),
    );

    bool ok = false;

    try {
      ok = await _controller.actualizarProducto(producto);
    } catch (e) {
      print(e);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Producto actualizado' : 'Error al actualizar'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Desayuno',
      'Comida',
      'Ensaladas',
      'Emparedados',
      'Bebida',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Producto")),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGEN
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _imagePath.isEmpty
                              ? const Center(child: Text("Sin imagen"))
                              : Image.asset(_imagePath, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _imagePathCtrl,
                          decoration: const InputDecoration(
                            labelText: "Ruta imagen",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _imagePath = _imagePathCtrl.text;
                            });
                          },
                          child: const Text("Actualizar imagen"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  /// FORMULARIO
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nombre",
                          ),
                        ),
                        TextFormField(
                          controller: _precioCtrl,
                          decoration: const InputDecoration(
                            labelText: "Precio",
                          ),
                        ),
                        TextFormField(
                          controller: _stockCtrl,
                          decoration: const InputDecoration(labelText: "Stock"),
                        ),
                        TextFormField(
                          controller: _descripcionCtrl,
                          decoration: const InputDecoration(
                            labelText: "Descripción",
                          ),
                        ),

                        const SizedBox(height: 10),

                        DropdownButton<String>(
                          value: _categoria,
                          isExpanded: true,
                          items: categorias
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() => _categoria = v!);
                          },
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _isSaving ? null : _onUpdate,
                          child: const Text("Actualizar Producto"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
