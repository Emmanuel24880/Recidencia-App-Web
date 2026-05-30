import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const backgroundColor = Color(0xFFF2B300);
  static const cardColor = Color(0xFF5B3A00);
  static const buttonColor = Color(0xFFF3C166);
  static const lineColor = Color(0xFFD9D9D9);

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final telefono = _telefonoCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final adminQuery = await FirebaseFirestore.instance
          .collection('administradores')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminDoc = adminQuery.docs.first;

        final data = adminDoc.data();

        final storedPassword = (data['contraseña'] ?? '').toString().trim();

        final estado = (data['estado'] ?? '').toString().trim();

        if (estado.toLowerCase() != 'activo') {
          throw Exception('Tu usuario está inactivo');
        }

        if (storedPassword != password) {
          throw Exception('Contraseña incorrecta');
        }

        if (!mounted) return;

        /// 🔥 ENTRAR COMO ADMIN
        context.goNamed('home', extra: data);

        return;
      }
      final cocineroQuery = await FirebaseFirestore.instance
          .collection('cocinero')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      if (cocineroQuery.docs.isNotEmpty) {
        final cocineroDoc = cocineroQuery.docs.first;

        final data = cocineroDoc.data();

        final storedPassword = (data['contraseña'] ?? '').toString().trim();

        final estado = (data['estado'] ?? '').toString().trim();

        if (estado.toLowerCase() != 'activo') {
          throw Exception('Tu usuario está inactivo');
        }

        if (storedPassword != password) {
          throw Exception('Contraseña incorrecta');
        }

        if (!mounted) return;

        /// 🔥 ENTRAR COMO COCINERO
        context.goNamed('cocinerohome', extra: data);

        return;
      }

      /// 🔥 SI NO EXISTE
      throw Exception('Usuario no encontrado');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),

          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: isMobile
                  ? Column(
                      children: [
                        _buildImagePanel(),
                        const SizedBox(height: 24),
                        _buildLoginPanel(),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: _buildImagePanel()),
                        const SizedBox(width: 28),
                        Expanded(flex: 4, child: _buildLoginPanel()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePanel() {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/pollo.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.18)),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/imagenes/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      height: 520,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Bienvenido!!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 46),
            _buildLineField(
              controller: _telefonoCtrl,
              icon: Icons.phone_outlined,
              hint: 'Teléfono',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            _buildLineField(
              controller: _passwordCtrl,
              icon: Icons.lock_outline,
              hint: 'Contraseña',
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                if (value.length < 4) {
                  return 'Mínimo 4 caracteres';
                }
                return null;
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 52),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Iniciar Sesion',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  '¿Olvidaste tu contraseña? ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => context.push('/registroadmin'),
                  child: const Text(
                    'Pulsa aquí',
                    style: TextStyle(
                      color: Color(0xFFF3C166),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white54, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
              suffixIcon: suffixIcon,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: lineColor, width: 1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: lineColor, width: 1.4),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.only(bottom: 10),
            ),
          ),
        ),
      ],
    );
  }
}
