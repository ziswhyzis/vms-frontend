import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/lattice_background.dart';

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
  final _fullName = TextEditingController();
  final _confirm = TextEditingController();

  bool _signUp = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _fullName.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _toggleMode() {
    final username = _username.text;
    setState(() {
      _signUp = !_signUp;
      _error = null;
      _fieldErrors = const {};
      _password.clear();
      _confirm.clear();
    });
    // Clear any validation messages left over from the other form.
    _formKey.currentState?.reset();
    _username.text = username;
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() {
        _fieldErrors = Map<String, String>.from(_fieldErrors)..remove(field);
      });
    }
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
      final user = _signUp
          ? await widget.authService.register(
              fullName: _fullName.text,
              username: _username.text,
              password: _password.text,
            )
          : await widget.authService.login(_username.text, _password.text);
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
        _fieldErrors = error.fieldErrors;
        _error = error.fieldErrors.isEmpty ? error.message : null;
      });
      _formKey.currentState?.validate();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = _signUp
            ? 'Something went wrong while creating your account. Please try again.'
            : 'Something went wrong while signing in. Please try again.';
      });
    }
  }

  String? _validateUsername(String? value) {
    final server = _fieldErrors['username'];
    if (server != null) {
      return server;
    }
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (!_signUp) {
      return null;
    }
    if (trimmed.length < 3 || trimmed.length > 60) {
      return 'Use 3-60 characters';
    }
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(trimmed)) {
      return 'Letters, numbers, dots, dashes and underscores only';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final server = _fieldErrors['password'];
    if (server != null) {
      return server;
    }
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (_signUp && password.length < 8) {
      return 'Use at least 8 characters';
    }
    if (_signUp && password.length > 72) {
      return 'Use 72 characters or fewer';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    final server = _fieldErrors['fullName'];
    if (server != null) {
      return server;
    }
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Full name is required';
    }
    if (trimmed.length < 2 || trimmed.length > 80) {
      return 'Use 2-80 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your password';
    }
    if (value != _password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LatticeScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          if (wide) {
            return Row(
              children: [
                const Expanded(child: _DescriptionPanel()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
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
                    const _DescriptionCopy(compact: true),
                    const SizedBox(height: 22),
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
      padding: EdgeInsets.all(compact ? 22 : 28),
      decoration: StarkChrome.card(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'OPERATOR',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: StarkColors.tealInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _signUp ? 'Create your account' : 'Sign in to the register',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: StarkColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _signUp
                  ? 'Set up an operator account to manage the vehicle fleet.'
                  : 'Use your Stark Group operator credentials to manage the vehicle fleet.',
              style: const TextStyle(fontSize: 13, color: StarkColors.inkMuted, height: 1.45),
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
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          color: StarkColors.roseInk,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_signUp) ...[
              TextFormField(
                key: const Key('login.fullName'),
                controller: _fullName,
                autofocus: true,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                onChanged: (_) => _clearFieldError('fullName'),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Jane Doe',
                  prefixIcon: Icon(Icons.badge_outlined, size: 19),
                ),
                validator: _validateFullName,
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              key: const Key('login.username'),
              controller: _username,
              autofocus: !_signUp,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              onChanged: (_) => _clearFieldError('username'),
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline, size: 19),
              ),
              validator: _validateUsername,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('login.password'),
              controller: _password,
              enabled: !_loading,
              obscureText: _obscure,
              textInputAction: _signUp ? TextInputAction.next : TextInputAction.done,
              autofillHints: [
                _signUp ? AutofillHints.newPassword : AutofillHints.password,
              ],
              onFieldSubmitted: (_) {
                if (!_signUp) {
                  _submit();
                }
              },
              onChanged: (_) => _clearFieldError('password'),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: _signUp ? 'At least 8 characters' : 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline, size: 19),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                ),
              ),
              validator: _validatePassword,
            ),
            if (_signUp) ...[
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('login.confirm'),
                controller: _confirm,
                enabled: !_loading,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  hintText: 'Repeat your password',
                  prefixIcon: Icon(Icons.lock_reset_outlined, size: 19),
                ),
                validator: _validateConfirm,
              ),
            ],
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
                    : Text(_signUp ? 'Create account' : 'Sign in'),
              ),
            ),
            const SizedBox(height: 6),
            // Wrap so the prompt and the link stay on one line on desktop and
            // fold onto two lines on narrow phones.
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _signUp ? 'Already have an account?' : 'New to the register?',
                  style: const TextStyle(fontSize: 12.5, color: StarkColors.inkMuted),
                ),
                TextButton(
                  key: const Key('login.toggleMode'),
                  onPressed: _loading ? null : _toggleMode,
                  child: Text(_signUp ? 'Sign in' : 'Create an account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionPanel extends StatelessWidget {
  const _DescriptionPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(56, 36, 40, 28),
      child: Column(
        children: [
          Spacer(),
          _DescriptionCopy(compact: false),
          Spacer(),
          Text(
            '© 2026 Stark Group',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: StarkColors.inkMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCopy extends StatelessWidget {
  const _DescriptionCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 30.0 : 42.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FleetIllustration(compact: compact),
        SizedBox(height: compact ? 18 : 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Stark Group Vehicles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: titleSize,
              fontWeight: FontWeight.w500,
              height: 1.12,
              letterSpacing: -0.4,
              color: StarkColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'All in one space',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
            height: 1.12,
            letterSpacing: -0.4,
            color: StarkColors.teal,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: const Text(
            'Every car, truck and bus in the fleet, kept in a single register.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              height: 1.55,
              color: StarkColors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// The swipe illustration sits above the statement. Widget tests skip the
/// animated decoder so `pumpAndSettle` can finish.
class _FleetIllustration extends StatelessWidget {
  const _FleetIllustration({this.compact = false});

  final bool compact;

  static const String asset = 'assets/vehicle-management-swipe.gif';

  bool get _inWidgetTest => WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');

  @override
  Widget build(BuildContext context) {
    final width = compact ? 220.0 : 280.0;
    final height = compact ? 124.0 : 158.0;
    if (_inWidgetTest) {
      return SizedBox(width: width, height: height);
    }
    // The source is black line art on a flat white field. Keying the white out
    // (alpha = 255 - red, colour forced to ink) lets the drawing sit directly
    // on the cream lattice instead of covering it with a white rectangle.
    return SizedBox(
      width: width,
      height: height,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          // R, G, B all collapse to ink; alpha comes from the line's darkness.
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          -1, 0, 0, 0, 248,
        ]),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          semanticLabel: 'Animated line drawing of a car',
        ),
      ),
    );
  }
}
