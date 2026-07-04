import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../controller/register_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenToState());
  }

  void _listenToState() {
    ref.listenManual(registerControllerProvider, (previous, next) {
      if (next.registerStatus == RegisterStatus.success &&
          next.registeredEmail != null) {
        context.pushNamed(
          AppRoutes.otpVerification,
          extra: next.registeredEmail,
        );
      } else if (next.registerStatus == RegisterStatus.error) {
        setState(() => _fieldErrors = next.fieldErrors);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _formKey.currentState?.validate(),
        );
        if (next.errorMessage != null) {
          _showSnackBar(next.errorMessage!);
        }
      }
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _submit() {
    setState(() => _fieldErrors = const {});
    ref.read(registerControllerProvider.notifier).clearFieldErrors();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(registerControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmController.text,
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final isLoading = state.registerStatus == RegisterStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundDecoration(),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const _LogoSection(),
                  const SizedBox(height: AppSpacing.lg),
                  const _Header(),
                  const SizedBox(height: AppSpacing.xl),
                  _RoleSelector(
                    selected: state.selectedRole,
                    onSelect: ref
                        .read(registerControllerProvider.notifier)
                        .setRole,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _InputField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) =>
                              _fieldErrors['name'] ?? Validators.name(v),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InputField(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.alternate_email_rounded,
                          validator: (v) =>
                              _fieldErrors['username'] ?? Validators.username(v),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InputField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              _fieldErrors['email'] ?? Validators.email(v),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PasswordField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscure: state.obscurePassword,
                          onToggle: ref
                              .read(registerControllerProvider.notifier)
                              .toggleObscurePassword,
                          validator: (v) =>
                              _fieldErrors['password'] ?? Validators.password(v),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PasswordField(
                          controller: _confirmController,
                          hintText: 'Confirm Password',
                          obscure: state.obscureConfirm,
                          onToggle: ref
                              .read(registerControllerProvider.notifier)
                              .toggleObscureConfirm,
                          validator: (v) =>
                              _fieldErrors['password_confirmation'] ??
                              Validators.confirmPassword(
                                  _passwordController.text)(v),
                          enabled: !isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _RegisterButton(isLoading: isLoading, onPressed: _submit),
                  const SizedBox(height: AppSpacing.xl),
                  _SignInRow(onTap: () => context.goNamed(AppRoutes.login)),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onSelect,
    required this.enabled,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleChip(
            label: 'Player',
            icon: Icons.sports_esports_rounded,
            value: 'player',
            isSelected: selected == 'player',
            onTap: enabled ? () => onSelect('player') : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _RoleChip(
            label: 'Organizer',
            icon: Icons.emoji_events_rounded,
            value: 'organizer',
            isSelected: selected == 'organizer',
            onTap: enabled ? () => onSelect('organizer') : null,
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
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
        prefixIcon:
            Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
      ),
      validator: validator,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: AppTextStyles.titleMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton(
      {required this.isLoading, required this.onPressed});

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
              borderRadius: BorderRadius.circular(AppRadius.full)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.textPrimary),
              )
            : const Text('Create Account', style: AppTextStyles.labelLarge),
      ),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? ',
            style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: onTap,
          child: const Text('Sign In', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.0),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.1,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accent.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.0),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.emoji_events_rounded,
              color: AppColors.textPrimary, size: 40),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'TOURNAX',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Account 🚀', style: AppTextStyles.displayLarge),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Join Tournax and start competing or organizing tournaments.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
