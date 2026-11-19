import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stark_group_vms/app.dart';
import 'package:stark_group_vms/core/api_client.dart';
import 'package:stark_group_vms/services/auth_service.dart';
import 'package:stark_group_vms/services/session_store.dart';
import 'package:stark_group_vms/services/vehicle_service.dart';

/// Real browser end-to-end test against a running backend.
///
/// Prerequisites:
///   1. Backend running on API_BASE_URL (default http://localhost:8080)
///   2. Chrome installed and chromedriver on PATH
///
/// Run:
///   flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/login_flow_test.dart \
///     -d chrome \
///     --dart-define=API_BASE_URL=http://localhost:8080
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('operator signs in and sees the fleet register', (tester) async {
    final apiClient = ApiClient();
    final app = StarkVmsApp(
      authService: AuthService(apiClient: apiClient, sessionStore: SessionStore()),
      vehicleService: VehicleService(apiClient: apiClient),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    if (find.byKey(const Key('login.username')).evaluate().isNotEmpty) {
      await tester.enterText(find.byKey(const Key('login.username')), 'admin');
      await tester.enterText(find.byKey(const Key('login.password')), 'admin123');
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Fleet Register'), findsOneWidget);
    expect(find.byKey(const Key('vehicles.add')), findsOneWidget);
    expect(find.byKey(const Key('pagination.summary')), findsOneWidget);
  });
}
