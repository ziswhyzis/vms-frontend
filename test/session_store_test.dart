import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_group_vms/app.dart';
import 'package:stark_group_vms/models/user.dart';
import 'package:stark_group_vms/services/auth_service.dart';
import 'package:stark_group_vms/services/session_store.dart';
import 'package:stark_group_vms/services/vehicle_service.dart';

import 'test_support.dart';

void main() {
  group('SessionStore', () {
    test('returns null when nothing is stored', () async {
      useEmptyPreferences();
      expect(await SessionStore().read(), isNull);
    });

    test('round-trips a saved session', () async {
      useEmptyPreferences();
      final store = SessionStore();
      final user = demoUser();

      await store.save(token: demoToken, user: user);
      final restored = await store.read();

      expect(restored, isNotNull);
      expect(restored!.token, demoToken);
      expect(restored.user.username, 'admin');
      expect(restored.user.fullName, 'Stark Group Administrator');
    });

    test('treats unparseable JSON as signed out instead of throwing', () async {
      useEmptyPreferences();
      SharedPreferences.setMockInitialValues({
        'vms.token': demoToken,
        'vms.user': 'this-is-not-json',
      });

      final store = SessionStore();
      expect(await store.read(), isNull);

      // The corrupt entry is cleared so the next launch starts clean.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('vms.user'), isNull);
      expect(prefs.getString('vms.token'), isNull);
    });

    test('treats a wrongly typed stored value as signed out', () async {
      useEmptyPreferences();
      SharedPreferences.setMockInitialValues({
        'vms.token': demoToken,
        'vms.user': 42,
      });

      expect(await SessionStore().read(), isNull);
    });

    test('clear removes the persisted session', () async {
      useEmptyPreferences();
      final store = SessionStore();
      await store.save(token: demoToken, user: demoUser());

      await store.clear();

      expect(await SessionStore().read(), isNull);
    });
  });

  group('SessionGate boot behaviour', () {
    Future<void> pumpApp(WidgetTester tester) async {
      final apiClient = testApiClient(MockClient((request) async => jsonResponse({})));
      await tester.pumpWidget(
        StarkVmsApp(
          authService: AuthService(apiClient: apiClient, sessionStore: SessionStore()),
          vehicleService: VehicleService(apiClient: apiClient),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the sign-in screen when no session is stored', (tester) async {
      useEmptyPreferences();
      await pumpApp(tester);

      expect(find.byKey(const Key('login.submit')), findsOneWidget);
    });

    testWidgets('never strands the operator on the splash when storage is corrupt', (tester) async {
      useEmptyPreferences();
      SharedPreferences.setMockInitialValues({
        'vms.token': demoToken,
        'vms.user': '{"broken": ',
      });

      await pumpApp(tester);

      expect(find.byKey(const Key('login.submit')), findsOneWidget);
    });

    testWidgets('restores a stored session and opens the fleet register', (tester) async {
      useEmptyPreferences();
      final store = SessionStore();
      await store.save(token: demoToken, user: User.fromJson(userJson()));

      tester.view.physicalSize = const Size(1500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final apiClient = testApiClient(MockClient((request) async {
        if (request.url.path == '/auth/me') {
          return jsonResponse(userJson());
        }
        return jsonResponse({
          'content': [vehicleJson()],
          'number': 0,
          'size': 10,
          'totalElements': 1,
          'totalPages': 1,
          'last': true,
        });
      }));

      await tester.pumpWidget(
        StarkVmsApp(
          authService: AuthService(apiClient: apiClient, sessionStore: store),
          vehicleService: VehicleService(apiClient: apiClient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fleet Register'), findsOneWidget);
      expect(find.text('DHA-GA-11-1001'), findsOneWidget);
    });

    testWidgets('returns to sign-in when the stored token is rejected', (tester) async {
      useEmptyPreferences();
      final store = SessionStore();
      await store.save(token: 'expired-token', user: User.fromJson(userJson()));

      final apiClient = testApiClient(MockClient((request) async {
        return jsonResponse({'status': 401, 'message': 'Token expired.'}, status: 401);
      }));

      await tester.pumpWidget(
        StarkVmsApp(
          authService: AuthService(apiClient: apiClient, sessionStore: store),
          vehicleService: VehicleService(apiClient: apiClient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login.submit')), findsOneWidget);
      expect(await store.read(), isNull);
    });
  });
}
