import 'dart:convert';

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

/// The sign-in card is taller than the default 800x600 test surface, so every
/// test uses a desktop-sized viewport and scrolls to a target before tapping.
Future<void> pumpLogin(
  WidgetTester tester,
  http.Client client, {
  ValueChanged<User>? onSignedIn,
}) async {
  tester.view.physicalSize = const Size(1400, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(loginApp(client, onSignedIn: onSignedIn));
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> openSignUp(WidgetTester tester, http.Client client, {ValueChanged<User>? onSignedIn}) async {
  await pumpLogin(tester, client, onSignedIn: onSignedIn);
  await tapKey(tester, 'login.toggleMode');
}

Future<void> fillSignUp(
  WidgetTester tester, {
  String fullName = 'Jane Doe',
  String username = 'jane.doe',
  String password = 'secret-passphrase',
  String? confirm,
}) async {
  await tester.enterText(find.byKey(const Key('login.fullName')), fullName);
  await tester.enterText(find.byKey(const Key('login.username')), username);
  await tester.enterText(find.byKey(const Key('login.password')), password);
  await tester.enterText(find.byKey(const Key('login.confirm')), confirm ?? password);
  await tester.pump();
}

void main() {
  setUp(useEmptyPreferences);

  testWidgets('validates empty credentials', (tester) async {
    await pumpLogin(tester, MockClient((request) async => jsonResponse({})));

    await tapKey(tester, 'login.submit');

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

    await pumpLogin(tester, client, onSignedIn: (user) => signedIn = user);

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), 'admin123');
    await tapKey(tester, 'login.submit');

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

    await pumpLogin(tester, client);

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), 'wrong');
    await tapKey(tester, 'login.submit');

    expect(find.byKey(const Key('login.error')), findsOneWidget);
    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  group('account creation', () {
    testWidgets('toggles between sign in and sign up', (tester) async {
      await pumpLogin(tester, MockClient((request) async => jsonResponse({})));

      expect(find.byKey(const Key('login.fullName')), findsNothing);
      expect(find.text('Sign in to the register'), findsOneWidget);

      await tapKey(tester, 'login.toggleMode');

      expect(find.byKey(const Key('login.fullName')), findsOneWidget);
      expect(find.byKey(const Key('login.confirm')), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);

      await tapKey(tester, 'login.toggleMode');

      expect(find.byKey(const Key('login.fullName')), findsNothing);
      expect(find.text('Sign in to the register'), findsOneWidget);
    });

    testWidgets('validates the sign-up form before calling the API', (tester) async {
      var called = false;
      await openSignUp(tester, MockClient((request) async {
        called = true;
        return jsonResponse({});
      }));

      await tapKey(tester, 'login.submit');

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm your password'), findsOneWidget);
      expect(called, false);
    });

    testWidgets('rejects mismatched passwords', (tester) async {
      await openSignUp(tester, MockClient((request) async => jsonResponse({})));

      await fillSignUp(tester, confirm: 'different-passphrase');
      await tapKey(tester, 'login.submit');

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('creates the account and signs the operator in', (tester) async {
      Map<String, dynamic>? posted;
      User? signedIn;
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/auth/register');
        posted = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          registerJson(username: 'jane.doe', fullName: 'Jane Doe'),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      await openSignUp(tester, client, onSignedIn: (user) => signedIn = user);

      await fillSignUp(tester);
      await tapKey(tester, 'login.submit');

      expect(posted, isNotNull);
      expect(posted!.keys, containsAll(<String>['username', 'fullName', 'password']));
      expect(posted!['username'], 'jane.doe');
      expect(posted!['fullName'], 'Jane Doe');
      expect(posted!['password'], 'secret-passphrase');
      expect(signedIn, isNotNull);
      expect(signedIn!.username, 'jane.doe');
    });

    testWidgets('shows a taken username under the username field', (tester) async {
      final client = MockClient((request) async {
        return jsonResponse(
          {
            'status': 409,
            'message': "Username 'jane.doe' is already taken.",
            'fieldErrors': {'username': 'Username already exists.'},
          },
          status: 409,
        );
      });

      await openSignUp(tester, client);

      await fillSignUp(tester);
      await tapKey(tester, 'login.submit');

      expect(find.text('Username already exists.'), findsOneWidget);
    });
  });
}
