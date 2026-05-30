import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/productos_web_controller.dart';
import '../../models/producto.dart';
import '../widgets/producto_web_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final ProductosWebController _controller = ProductosWebController();

  final List<String> categoria = [
    'Todos',
    'Desayuno',
    'Comida',
    'Ensalada',
    'Emparedado',
    'Bebida',
  ];

  String categoriaSeleccionada = 'Desayuno';

  /// 🔥 NUEVO: control de activos / inactivos
  bool _mostrarActivos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),

      /// 🔥 DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFF4B400)),
              child: Row(
                children: const [
                  Icon(Icons.restaurant, size: 40),
                  SizedBox(width: 10),
                  Text("Menú", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Activos"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _mostrarActivos = true;
                });
              },
            ),

            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text("Inactivos"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _mostrarActivos = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text("Administrador de meseros"),
              onTap: () {
                Navigator.pop(context);
                context.push('/meseros');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.black),
              title: const Text("Ventas del día"),
              onTap: () {
                Navigator.pop(context);
                context.push('/ventas');
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF4B400),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    /// 🔥 BOTÓN MENU FUNCIONAL
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 34,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/imagenes/logon.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () {
                        context.push('/agregar-producto');
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// CATEGORÍAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    children: categoria.map((categoria) {
                      final selected = categoriaSeleccionada == categoria;

                      return ChoiceChip(
                        label: Text(categoria),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            categoriaSeleccionada = categoria;
                          });
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          /// CONTENIDO
          Expanded(
            child: StreamBuilder<List<Producto>>(
              stream: _controller.streamTodosLosProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Ocurrió un error al cargar los productos'),
                  );
                }

                final productos = snapshot.data ?? [];

                /// 🔥 FILTRO ACTIVOS / INACTIVOS
                final filtradosEstado = productos.where((p) {
                  return _mostrarActivos ? p.activo == true : p.activo == false;
                }).toList();

                /// 🔥 FILTRO POR CATEGORÍA
                final filtrados = _controller.filtrarPorCategoria(
                  filtradosEstado,
                  categoriaSeleccionada,
                );

                if (filtrados.isEmpty) {
                  return Center(
                    child: Text(
                      _mostrarActivos
                          ? 'No hay productos activos'
                          : 'No hay productos inactivos',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _mostrarActivos
                              ? "$categoriaSeleccionada (Activos)"
                              : "$categoriaSeleccionada (Inactivos)",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: GridView.builder(
                          itemCount: filtrados.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.7,
                              ),
                          itemBuilder: (context, index) {
                            return ProductoWebCard(producto: filtrados[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
