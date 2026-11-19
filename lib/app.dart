import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/vehicles_screen.dart';
import 'services/auth_service.dart';
import 'services/vehicle_service.dart';
import 'widgets/brand_mark.dart';

class StarkVmsApp extends StatelessWidget {
  const StarkVmsApp({
    super.key,
    required this.authService,
    required this.vehicleService,
  });

  final AuthService authService;
  final VehicleService vehicleService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stark Group VMS',
      debugShowCheckedModeBanner: false,
      theme: buildStarkTheme(),
      home: SessionGate(authService: authService, vehicleService: vehicleService),
    );
  }
}

enum _Phase { restoring, signedOut, signedIn }

/// Restores a stored session before deciding which screen to show.
class SessionGate extends StatefulWidget {
  const SessionGate({
    super.key,
    required this.authService,
    required this.vehicleService,
  });

  final AuthService authService;
  final VehicleService vehicleService;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  _Phase _phase = _Phase.restoring;
  User? _user;

  @override
  void initState() {
    super.initState();
    widget.authService.apiClient.onUnauthorized = _handleSessionExpired;
    _restore();
  }

  @override
  void dispose() {
    widget.authService.apiClient.onUnauthorized = null;
    super.dispose();
  }

  Future<void> _restore() async {
    User? user;
    try {
      user = await widget.authService.restoreSession();
    } catch (_) {
      // A failed restore must never strand the operator on the splash screen.
      user = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
      _phase = user == null ? _Phase.signedOut : _Phase.signedIn;
    });
  }

  void _handleSessionExpired() {
    if (!mounted) {
      return;
    }
    setState(() {
      _user = null;
      _phase = _Phase.signedOut;
    });
  }

  Future<void> _signOut() async {
    await widget.authService.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = null;
      _phase = _Phase.signedOut;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.restoring:
        return const _SplashScreen();
      case _Phase.signedOut:
        return LoginScreen(
          authService: widget.authService,
          onSignedIn: (user) => setState(() {
            _user = user;
            _phase = _Phase.signedIn;
          }),
        );
      case _Phase.signedIn:
        return VehiclesScreen(
          vehicleService: widget.vehicleService,
          user: _user!,
          onSignOut: _signOut,
        );
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StarkColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64, glow: true),
            const SizedBox(height: 18),
            const Text(
              'STARK GROUP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'VEHICLE MANAGEMENT SYSTEM',
              style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: StarkColors.cyan.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
