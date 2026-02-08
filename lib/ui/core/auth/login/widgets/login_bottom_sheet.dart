import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/data/services/auth_service.dart';
import 'package:flutter_application_test/routes/app_routes.dart';
import 'package:flutter_application_test/ui/widgets/custom_text_input.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:flutter_application_test/ui/core/ui/widgets/custom_elevated_buttom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginBottomSheet extends ConsumerStatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    Navigator.of(context).pop();

    setState(() => _isSubmitting = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      
      // Não precisa mais navegar manualmente
      // O AuthWrapper vai detectar a mudança de estado e navegar automaticamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.8,
      minChildSize: 0.2,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BorderRadiusConstants.borderRadius),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entre com a sua conta',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isSubmitting: _isSubmitting,
                  onLogin: _login,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onLogin;

  const CustomForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 24.0),
        CustomTextInput(
          label: 'Email',
          controller: emailController,
        ),
        SizedBox(height: 16.0),
        CustomTextInput(
          label: 'Senha',
          isPassword: true,
          controller: passwordController,
        ),
        SizedBox(height: 8.0),
        Container(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.fromMap({
                WidgetState.pressed: EdgeInsets.zero,
              }),
            ),
            onPressed: () {
              // TODO: Implement password reset
            },
            child: Text(
              'Esqueci minha senha',
              style: TextStyle(
                color: AppTheme.onSurface,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        CustomFilledButton(
          label: isSubmitting ? 'Entrando...' : 'Entrar',
          onPressed: isSubmitting ? () {} : onLogin,
          backgroundColor: AppTheme.primary,
        ),
        SizedBox(height: 8.0),
        CustomOutlinedButton(
          label: 'Criar Conta',
          onPressed: () {
            Navigator.of(context).pop();
            navigatorKey.currentState?.pushNamed(
              AppRoutes.accountCreationScreen,
            );
          },
          borderColor: AppTheme.primary,
        ),
      ],
    );
  }
}
