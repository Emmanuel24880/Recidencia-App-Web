import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistroAdministradorView extends StatefulWidget {
  const RegistroAdministradorView({super.key});

  @override
  State<RegistroAdministradorView> createState() =>
      _RegistroAdministradorViewState();
}

class _RegistroAdministradorViewState extends State<RegistroAdministradorView> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
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
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrarAdministrador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nombreCompleto = _nombreCtrl.text.trim();
      final telefono = _telefonoCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      // Generar UID basado en el teléfono
      final uid = telefono.replaceAll(RegExp(r'[^\w]'), '');

      final docRef = FirebaseFirestore.instance
          .collection('administradores')
          .doc(uid);

      // Verificar si ya existe (más rápido que query)
      final doc = await docRef.get();

      if (doc.exists) {
        throw Exception('El teléfono ya está registrado');
      }

      // Guardar administrador
      await docRef.set({
        'nombreCompleto': nombreCompleto,
        'telefono': telefono,
        'contraseña': password,
        'estado': 'activo',
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Administrador registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(); // Regresar
    } catch (e) {
      print('ERROR FIRESTORE: $e');

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
      appBar: AppBar(
        title: const Text('Registrar administrador'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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
                        _buildFormPanel(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(flex: 6, child: _buildImagePanel()),
                        const SizedBox(width: 28),
                        Expanded(flex: 4, child: _buildFormPanel()),
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

  Widget _buildFormPanel() {
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
          children: [
            const Text(
              'Nuevo Administrador',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            _buildLineField(
              controller: _nombreCtrl,
              icon: Icons.badge_outlined,
              hint: 'Nombre completo',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _buildLineField(
              controller: _telefonoCtrl,
              icon: Icons.phone_outlined,
              hint: 'Teléfono',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _buildLineField(
              controller: _passwordCtrl,
              icon: Icons.lock_outline,
              hint: 'Contraseña',
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la contraseña';
                }
                if (value.length < 6) {
                  return 'Mínimo 6 caracteres';
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarAdministrador,
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
                        'Registrar administrador',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
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
        Icon(icon, color: Colors.white54, size: 36),
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
