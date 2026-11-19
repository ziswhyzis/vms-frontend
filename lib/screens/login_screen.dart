import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/brand_mark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onSignedIn,
  });

  final AuthService authService;
  final ValueChanged<User> onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await widget.authService.login(_username.text, _password.text);
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      widget.onSignedIn(user);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Something went wrong while signing in. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StarkColors.canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          if (wide) {
            return Row(
              children: [
                const Expanded(flex: 11, child: _BrandPanel()),
                Expanded(
                  flex: 9,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: _buildForm(compact: false),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [StarkColors.navy, StarkColors.navySoft],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      child: const BrandWordmark(markSize: 36),
                    ),
                    const SizedBox(height: 18),
                    _buildForm(compact: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StarkColors.line),
        boxShadow: [
          BoxShadow(
            color: StarkColors.navy.withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'FLEET OPERATIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: StarkColors.cyanDeep,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to the register',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: StarkColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use your Stark Group operator credentials to manage the vehicle fleet.',
              style: TextStyle(fontSize: 13, color: StarkColors.inkMuted, height: 1.45),
            ),
            const SizedBox(height: 22),
            if (_error != null) ...[
              Container(
                key: const Key('login.error'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StarkColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: StarkColors.red.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, size: 17, color: StarkColors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFFB0182A), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: const Key('login.username'),
              controller: _username,
              autofocus: true,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'e.g. admin',
                prefixIcon: Icon(Icons.person_outline, size: 19),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Username is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('login.password'),
              controller: _password,
              enabled: !_loading,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline, size: 19),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('login.submit'),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : const Text('Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [StarkColors.navy, StarkColors.navySoft, Color(0xFF001A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(320, StarkColors.cyan.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _glowCircle(360, const Color(0xFF0060F0).withValues(alpha: 0.12)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 48, 52, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandWordmark(markSize: 46),
                const Spacer(),
                const Text(
                  'Fleet operations,\nunder control.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'STARK GROUP VEHICLE MANAGEMENT SYSTEM',
                  style: TextStyle(
                    color: StarkColors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text(
                    'Register, update and retire every vehicle in the Stark Group fleet from one register.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '© 2026 Stark Group',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

}
