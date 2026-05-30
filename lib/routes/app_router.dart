// lib/routes/app_router.dart
import 'package:app_web_1/models/producto.dart';
import 'package:app_web_1/views/registroadmin.dart';
import 'package:app_web_1/views/screens/add_product_view.dart';
import 'package:app_web_1/views/screens/cocinero_home.dart';
import 'package:app_web_1/views/screens/home_view.dart';
import 'package:app_web_1/views/screens/login.dart';
import 'package:app_web_1/views/screens/meseros_view.dart';
import 'package:app_web_1/views/screens/ventas_view.dart';
import 'package:app_web_1/views/screens/view_product_view.dart';
import 'package:app_web_1/views/widgets/edit_product_view.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/registroadmin',
      name: 'registroadmin',
      builder: (context, state) => const RegistroAdministradorView(),
    ),
    GoRoute(
      path: '/agregar-producto',
      name: 'agregar-producto',
      builder: (context, state) => const AddProductView(),
    ),
    GoRoute(
      path: '/editar-producto',
      builder: (context, state) {
        final producto = state.extra as Producto;
        return EditProductView(producto: producto);
      },
    ),
    GoRoute(
      path: '/ver-producto',
      builder: (context, state) {
        final producto = state.extra as Producto;
        return ViewProductView(producto: producto);
      },
    ),
    GoRoute(
      path: '/cocinerohome',
      name: 'cocinerohome',
      builder: (context, state) {
        final cocinero = state.extra as Map<String, dynamic>;

        return CocineroHome(cocinero: cocinero);
      },
    ),
    GoRoute(path: '/meseros', builder: (context, state) => const MeserosView()),
    GoRoute(path: '/ventas', builder: (context, state) => const VentasView()),
  ],
);
