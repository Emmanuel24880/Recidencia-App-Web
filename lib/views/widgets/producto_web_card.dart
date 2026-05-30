import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/producto.dart';
import '../../controllers/productos_web_controller.dart';

class ProductoWebCard extends StatelessWidget {
  final Producto producto;

  const ProductoWebCard({super.key, required this.producto});

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final controller = ProductosWebController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar producto"),
          content: Text("¿Estás seguro de eliminar '${producto.nombre}'?"),
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
      try {
        await controller.eliminarProducto(producto.id);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto eliminado"),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar"),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/ver-producto', extra: producto);
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey.shade300,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  producto.imagenUrl.isNotEmpty
                      ? Image.network(
                          producto.imagenUrl,
                          height: 280,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 280,
                              color: Colors.red,
                              child: const Center(
                                child: Text(
                                  "Error cargando imagen",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.black54,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Sin imagen",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Text(
                      producto.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _confirmarEliminacion(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.delete, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
