import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/services/auth_service.dart';
import 'package:flutter_application_test/data/services/firestore_service.dart';
import 'package:flutter_application_test/routes/app_routes.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:flutter_application_test/ui/core/ui/widgets/custom_elevated_buttom.dart';
import 'package:flutter_application_test/ui/widgets/custom_text_input.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create Firebase Auth account
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await _authService.updateDisplayName(name);

      // Create Firestore user profile
      await _firestoreService.createUserProfile(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
        (route) => false,
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Crie sua conta',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os dados abaixo para continuar.',
                style: TextStyle(
                  color: AppTheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              CustomTextInput(
                label: 'Nome',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              CustomTextInput(
                label: 'Email',
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              CustomTextInput(
                label: 'Senha',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),

              CustomTextInput(
                label: 'Confirmar senha',
                isPassword: true,
                controller: _confirmPasswordController,
              ),

              const SizedBox(height: 24),

              CustomFilledButton(
                label: _isSubmitting ? 'Criando...' : 'Criar conta',
                onPressed: _isSubmitting ? () {} : _createAccount,
                backgroundColor: AppTheme.primary,
              ),
              const SizedBox(height: 8),
              CustomOutlinedButton(
                label: 'Já tenho conta',
                onPressed: () => Navigator.of(context).pop(),
                borderColor: AppTheme.primary,
                textColor: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}