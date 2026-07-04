import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../controller/login_controller.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final void Function(String emailOrUsername, String password) onSubmit;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.status == LoginStatus.loading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputField(
            controller: _emailController,
            hintText: 'Email or Username',
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.emailOrUsername,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          _PasswordField(
            controller: _passwordController,
            obscure: state.obscurePassword,
            onToggle: ref.read(loginControllerProvider.notifier).togglePasswordVisibility,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RememberMeForgotRow(isLoading: isLoading),
          const SizedBox(height: AppSpacing.lg),
          _LoginButton(isLoading: isLoading, onPressed: _submit),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: AppTextStyles.titleMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
      ),
      validator: validator,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: AppTextStyles.titleMedium,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
      validator: Validators.password,
    );
  }
}

class _RememberMeForgotRow extends ConsumerWidget {
  const _RememberMeForgotRow({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(loginControllerProvider.select((s) => s.rememberMe));

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: rememberMe,
            onChanged: isLoading
                ? null
                : (_) => ref.read(loginControllerProvider.notifier).toggleRememberMe(),
            activeColor: AppColors.primary,
            side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: isLoading
              ? null
              : () => ref.read(loginControllerProvider.notifier).toggleRememberMe(),
          child: const Text('Remember me', style: AppTextStyles.bodySmall),
        ),
        const Spacer(),
        TextButton(
          onPressed: isLoading ? null : () => context.pushNamed(AppRoutes.forgotPassword),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
          child: const Text('Forgot Password?', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textPrimary,
                ),
              )
            : const Text('Sign In', style: AppTextStyles.labelLarge),
      ),
    );
  }
}
