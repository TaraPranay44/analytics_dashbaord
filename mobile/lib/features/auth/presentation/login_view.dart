import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_view.dart';
import 'auth_role_provider.dart';
import 'coming_soon_view.dart';

/// Sign-in screen - visual design follows the attached mobile mockup
/// (`mobile-login (1).html`: gradient hero + email/password form).
///
/// Performs a real Frappe session login (`DioClient.login`, standard
/// Frappe-core `/api/method/login` - see the open-gap note at the top of
/// docs/06_MOBILE_RULES.md) against whatever `ApiConstants.baseUrl` points
/// at, then routes to the CEO dashboard on success. This intentionally
/// deviates from the reference mockup's own script (which signs in on any
/// non-empty input, matching web's `authRoleStore.ts` demo) now that a real
/// bench is available to authenticate against - see the docs note for the
/// full history of this decision. Manager/Employee buttons remain a pure
/// client-side role pick (no backend call) per docs/06_MOBILE_RULES.md §8 -
/// those dashboards don't exist yet regardless of credentials.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailInvalid = false;
  bool _passwordInvalid = false;
  bool _isSubmitting = false;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final emailEmpty = email.isEmpty;
    final passwordEmpty = password.isEmpty;
    setState(() {
      _emailInvalid = emailEmpty;
      _passwordInvalid = passwordEmpty;
      _authError = null;
    });
    if (emailEmpty || passwordEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(dioClientProvider).login(email, password);
      if (!mounted) return;
      ref.read(authRoleProvider.notifier).state = PortalRole.ceo;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardView()));
    } catch (_) {
      if (!mounted) return;
      setState(() => _authError = 'Sign-in failed - check your credentials and try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _chooseComingSoon(PortalRole role, String label) {
    ref.read(authRoleProvider.notifier).state = role;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComingSoonView(roleLabel: label)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOuter,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _MeshHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.violet500.withValues(alpha: 0.12), AppColors.pink500.withValues(alpha: 0.12)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.violet500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Welcome back', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in with your company credentials.',
                      style: TextStyle(fontSize: 12, color: AppColors.ink500),
                    ),
                    const SizedBox(height: 18),
                    _LabeledField(
                      label: 'Email or username',
                      controller: _emailController,
                      hint: 'you@company.com',
                      invalid: _emailInvalid,
                      errorText: StringConstants.emailRequired,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      obscure: true,
                      invalid: _passwordInvalid,
                      errorText: StringConstants.passwordRequired,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?', style: TextStyle(fontSize: 11.5, color: AppColors.violet500)),
                      ),
                    ),
                    if (_authError != null) ...[
                      const SizedBox(height: 6),
                      Text(_authError!, style: const TextStyle(fontSize: 11.5, color: AppColors.danger)),
                    ],
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: AppColors.gradientBrand, borderRadius: BorderRadius.circular(12)),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _chooseComingSoon(PortalRole.manager, 'Manager'),
                            child: const Text('Manager', style: TextStyle(fontSize: 11.5)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _chooseComingSoon(PortalRole.employee, 'Employee'),
                            child: const Text('Employee', style: TextStyle(fontSize: 11.5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔐', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Your role and dashboard are determined automatically from your account — there's nothing to select here.",
                              style: TextStyle(fontSize: 11, color: AppColors.ink500, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      StringConstants.demoNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, color: AppColors.ink300),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    required this.invalid,
    required this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool invalid;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: invalid ? AppColors.danger : AppColors.border),
            ),
          ),
        ),
        if (invalid) ...[
          const SizedBox(height: 4),
          Text(errorText, style: const TextStyle(fontSize: 11, color: AppColors.danger)),
        ],
      ],
    );
  }
}

class _MeshHero extends StatelessWidget {
  const _MeshHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: const BoxDecoration(color: AppColors.space900),
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(top: -80, left: -100, child: _Orb(size: 220, color: AppColors.violet500, opacity: 0.55)),
            const Positioned(top: 20, right: -80, child: _Orb(size: 200, color: AppColors.pink500, opacity: 0.4)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(gradient: AppColors.gradientBrand, borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      StringConstants.appName.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  StringConstants.loginHeadline,
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, height: 1.18),
                ),
                const SizedBox(height: 8),
                const Text(
                  StringConstants.loginSub,
                  style: TextStyle(color: Color(0xB8FFFFFF), fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _GlassBadge(value: '30,000', label: 'employees')),
                    const SizedBox(width: 8),
                    Expanded(child: _GlassBadge(value: '11M+', label: 'activity logs')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.amber500)),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(label, style: const TextStyle(color: Color(0xA6FFFFFF), fontSize: 9.5)),
            ],
          ),
        ],
      ),
    );
  }
}
