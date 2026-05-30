import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../controllers/productos_web_controller.dart';

class ViewProductView extends StatefulWidget {
  final Producto producto;

  const ViewProductView({super.key, required this.producto});

  @override
  State<ViewProductView> createState() => _ViewProductViewState();
}

class _ViewProductViewState extends State<ViewProductView> {
  final _controller = ProductosWebController();

  late Producto producto;
  bool _editMode = false;

  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;

  @override
  void initState() {
    super.initState();

    producto = widget.producto;

    _nombreCtrl = TextEditingController(text: producto.nombre);

    _precioCtrl = TextEditingController(text: producto.precio.toString());

    _descripcionCtrl = TextEditingController(text: producto.descripcion);
  }

  Future<void> _guardarCambios() async {
    final actualizado = Producto(
      id: producto.id,
      nombre: _nombreCtrl.text,
      precio: double.parse(_precioCtrl.text),
      categoria: producto.categoria,
      descripcion: _descripcionCtrl.text,
      imagenUrl: producto.imagenUrl,
      activo: producto.activo,
      stock: producto.stock,
    );

    await _controller.actualizarProducto(actualizado);

    setState(() {
      producto = actualizado;
      _editMode = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Producto actualizado")));
  }

  Future<void> _eliminarProducto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Eliminar producto"),
          content: Text("¿Seguro que deseas eliminar '${producto.nombre}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),

              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _controller.eliminarProducto(producto.id);

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  Future<void> _toggleActivo() async {
    final nuevoEstado = !producto.activo;

    await _controller.actualizarProducto(
      producto.copyWith(activo: nuevoEstado),
    );

    setState(() {
      producto = producto.copyWith(activo: nuevoEstado);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
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

                  Align(
                    alignment: Alignment.centerRight,

                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 30),

                      onPressed: _eliminarProducto,
                    ),
                  ),
                ],
              ),
            ),

            /// CONTENIDO
            Expanded(
              child: Container(
                width: double.infinity,

                margin: const EdgeInsets.all(20),

                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 223, 199),

                  borderRadius: BorderRadius.circular(35),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1550),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// IMAGEN
                        Expanded(
                          flex: 4,

                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),

                              child: producto.imagenUrl.startsWith('assets/')
                                  ? Image.asset(
                                      producto.imagenUrl,
                                      height: 430,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      producto.imagenUrl,
                                      height: 430,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 45),

                        /// INFO
                        Expanded(
                          flex: 5,

                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// TITULO
                                Center(
                                  child: Text(
                                    producto.activo
                                        ? "Producto Activo"
                                        : "Producto Inactivo",

                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// BOTON
                                Center(
                                  child: SizedBox(
                                    width: 260,
                                    height: 55,

                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _editMode = !_editMode;
                                        });
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),

                                      child: Text(
                                        _editMode ? "Cancelar" : "Modificar",

                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 35),

                                /// NOMBRE Y PRECIO
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          const Text(
                                            "Nombre",

                                            style: TextStyle(fontSize: 18),
                                          ),

                                          const SizedBox(height: 10),

                                          _editMode
                                              ? TextField(
                                                  controller: _nombreCtrl,

                                                  decoration: InputDecoration(
                                                    filled: true,

                                                    fillColor: Colors.white,

                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),

                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                )
                                              : _buildInfoBox(_nombreCtrl.text),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 25),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          const Text(
                                            "Precio",

                                            style: TextStyle(fontSize: 18),
                                          ),

                                          const SizedBox(height: 10),

                                          _editMode
                                              ? TextField(
                                                  controller: _precioCtrl,

                                                  decoration: InputDecoration(
                                                    prefixText: "\$ ",

                                                    filled: true,

                                                    fillColor: Colors.white,

                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),

                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                )
                                              : _buildInfoBox(
                                                  "\$ ${_precioCtrl.text}",
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                /// STOCK
                                const Text(
                                  "Stock",

                                  style: TextStyle(fontSize: 18),
                                ),

                                const SizedBox(height: 10),

                                _buildInfoBox(producto.stock.toString()),

                                const SizedBox(height: 25),

                                /// CATEGORIA
                                const Text(
                                  "Categoría",

                                  style: TextStyle(fontSize: 18),
                                ),

                                const SizedBox(height: 12),

                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,

                                  children: [
                                    _buildCategory("Desayuno"),

                                    _buildCategory("Comida"),

                                    _buildCategory("Ensaladas"),

                                    _buildCategory("Emparedados"),

                                    _buildCategory("Bebida"),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                /// DESCRIPCION
                                const Text(
                                  "Descripción",

                                  style: TextStyle(fontSize: 18),
                                ),

                                const SizedBox(height: 10),

                                _editMode
                                    ? TextField(
                                        controller: _descripcionCtrl,

                                        maxLines: 4,

                                        decoration: InputDecoration(
                                          filled: true,

                                          fillColor: Colors.white,

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),

                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,

                                        constraints: const BoxConstraints(
                                          minHeight: 120,
                                        ),

                                        padding: const EdgeInsets.all(18),

                                        decoration: BoxDecoration(
                                          color: Colors.white,

                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Align(
                                          alignment: Alignment.topLeft,

                                          child: Text(
                                            _descripcionCtrl.text,

                                            style: const TextStyle(
                                              fontSize: 16,

                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),

                                const SizedBox(height: 30),

                                /// ACTIVO
                                Row(
                                  children: [
                                    const Text(
                                      "Activo",

                                      style: TextStyle(fontSize: 18),
                                    ),

                                    const SizedBox(width: 12),

                                    Switch(
                                      value: producto.activo,

                                      onChanged: (_) => _toggleActivo(),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                if (_editMode)
                                  SizedBox(
                                    width: double.infinity,

                                    height: 55,

                                    child: ElevatedButton(
                                      onPressed: _guardarCambios,

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),

                                      child: const Text(
                                        "Guardar cambios",

                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoBox(String text) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Text(
        text,

        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildCategory(String categoria) {
    final selected = producto.categoria == categoria;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),

      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade200 : Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.purple.shade100),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          if (selected)
            const Padding(
              padding: EdgeInsets.only(right: 8),

              child: Icon(Icons.check, size: 18),
            ),

          Text(categoria, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
