// lib/views/screens/admin_add_product_view.dart
import 'package:flutter/material.dart';

import '../../controllers/productos_web_controller.dart';
import '../../models/producto.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProductosWebController();

  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: "10");
  final _imagePathCtrl = TextEditingController();

  String _categoria = 'Desayuno';
  bool _isSaving = false;
  bool _activo = true;

  String? _imagePath;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _descripcionCtrl.dispose();
    _stockCtrl.dispose();
    _imagePathCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath == null || _imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una ruta de imagen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool ok = false;

    try {
      final producto = Producto(
        id: '',
        nombre: _nombreCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim()),
        categoria: _categoria,
        descripcion: _descripcionCtrl.text.trim(),
        imagenUrl: _imagePath!, // 🔥 ahora es ruta local
        activo: _activo,
        stock: int.parse(_stockCtrl.text.trim()),
      );

      ok = await _controller
          .crearProducto(producto)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('ERROR: $e');
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '¡Producto creado!' : 'Error al guardar'),
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/imagenes/logon.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔥 PREVIEW IMAGEN
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 320,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Center(
                                child: _imagePath == null || _imagePath!.isEmpty
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.image_outlined, size: 40),
                                          SizedBox(height: 10),
                                          Text("Sin imagen"),
                                          Text(
                                            "Ingresa ruta de imagen",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          _imagePath!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Text(
                                                    "Imagen no encontrada",
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 40),

                          /// FORMULARIO
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInput(
                                  label: "Nombre",
                                  controller: _nombreCtrl,
                                ),
                                const SizedBox(height: 16),
                                _buildInput(
                                  label: "Precio",
                                  controller: _precioCtrl,
                                  keyboard: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                _buildInput(
                                  label: "Stock",
                                  controller: _stockCtrl,
                                  keyboard: TextInputType.number,
                                ),
                                const SizedBox(height: 16),

                                const Text("Categoría"),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  children: categorias.map((c) {
                                    final selected = _categoria == c;
                                    return ChoiceChip(
                                      label: Text(c),
                                      selected: selected,
                                      onSelected: (_) {
                                        setState(() => _categoria = c);
                                      },
                                      selectedColor: Colors.blue.shade200,
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 16),

                                _buildInput(
                                  label: "Descripción",
                                  controller: _descripcionCtrl,
                                  maxLines: 3,
                                ),

                                const SizedBox(height: 16),

                                /// 🔥 INPUT RUTA IMAGEN
                                TextFormField(
                                  controller: _imagePathCtrl,
                                  decoration: InputDecoration(
                                    labelText: "Ruta de imagen (assets)",
                                    hintText: "assets/bebidas/coca.jpg",
                                    filled: true,
                                    fillColor: const Color(0xFFF3F3F3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _imagePath = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _onSave,
                                    icon: const Icon(Icons.save),
                                    label: _isSaving
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text("Guardar Producto"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B8DEF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F3F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
