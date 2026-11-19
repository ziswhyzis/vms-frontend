import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stark_group_vms/core/theme.dart';
import 'package:stark_group_vms/models/user.dart';
import 'package:stark_group_vms/screens/login_screen.dart';
import 'package:stark_group_vms/services/auth_service.dart';
import 'package:stark_group_vms/services/session_store.dart';

import 'test_support.dart';

Widget loginApp(http.Client client, {ValueChanged<User>? onSignedIn}) {
  final apiClient = testApiClient(client);
  final authService = AuthService(apiClient: apiClient, sessionStore: SessionStore());
  return MaterialApp(
    theme: buildStarkTheme(),
    home: LoginScreen(
      authService: authService,
      onSignedIn: onSignedIn ?? (_) {},
    ),
  );
}

void main() {
  setUp(useEmptyPreferences);

  testWidgets('validates empty credentials', (tester) async {
    await tester.pumpWidget(loginApp(MockClient((request) async => jsonResponse({}))));

    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('signs in with valid credentials and calls back', (tester) async {
    User? signedIn;
    final client = MockClient((request) async {
      expect(request.url.path, '/auth/login');
      expect(request.method, 'POST');
      expect(request.body.contains('admin'), true);
      return http.Response(
        loginJson(),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(loginApp(client, onSignedIn: (user) => signedIn = user));

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), 'admin123');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(signedIn, isNotNull);
    expect(signedIn!.username, 'admin');
    expect(signedIn!.role, 'ADMIN');
  });

  testWidgets('shows the backend message for rejected credentials', (tester) async {
    final client = MockClient((request) async {
      return jsonResponse(
        {'status': 401, 'message': 'Invalid username or password.'},
        status: 401,
      );
    });

    await tester.pumpWidget(loginApp(client));

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), 'wrong');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login.error')), findsOneWidget);
    expect(find.text('Invalid username or password.'), findsOneWidget);
  });
}
