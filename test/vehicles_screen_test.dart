import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stark_group_vms/core/theme.dart';
import 'package:stark_group_vms/screens/vehicles_screen.dart';
import 'package:stark_group_vms/services/vehicle_service.dart';

import 'test_support.dart';

Widget vehiclesApp(http.Client client) {
  final apiClient = testApiClient(client);
  return MaterialApp(
    theme: buildStarkTheme(),
    home: VehiclesScreen(
      vehicleService: VehicleService(apiClient: apiClient),
      user: demoUser(),
      onSignOut: () async {},
    ),
  );
}

Future<void> pumpDesktop(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(1500, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

void main() {
  setUp(useEmptyPreferences);

  testWidgets('renders paginated vehicle list from the API', (tester) async {
    final pageRequests = <int>[];
    final client = MockClient((request) async {
      pageRequests.add(int.parse(request.url.queryParameters['page'] ?? '0'));
      return http.Response(pageJson(page: pageRequests.last), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    expect(find.text('Fleet Register'), findsOneWidget);
    expect(find.text('DHA-GA-11-1001'), findsOneWidget);
    expect(find.text('Showing 1–10 of 24'), findsOneWidget);
    expect(find.text('Page 1 of 3'), findsOneWidget);
    expect(find.text('24 vehicles'), findsOneWidget);
  });

  testWidgets('requests the next page server-side', (tester) async {
    final pageRequests = <int>[];
    final client = MockClient((request) async {
      pageRequests.add(int.parse(request.url.queryParameters['page'] ?? '0'));
      return http.Response(pageJson(page: pageRequests.last), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('pagination.next')));
    await tester.pumpAndSettle();

    expect(pageRequests.last, 1);
    expect(find.text('Showing 11–20 of 24'), findsOneWidget);
    expect(find.text('Page 2 of 3'), findsOneWidget);
    expect(find.text('DHA-GA-11-1011'), findsOneWidget);
  });

  testWidgets('changes page size and resets to page zero', (tester) async {
    final requests = <String, String>{};
    final client = MockClient((request) async {
      requests['page'] = request.url.queryParameters['page'] ?? '0';
      requests['size'] = request.url.queryParameters['size'] ?? '0';
      return http.Response(pageJson(page: int.parse(requests['page']!), size: int.parse(requests['size']!)), 200,
          headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('pagination.size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').last);
    await tester.pumpAndSettle();

    expect(requests['page'], '0');
    expect(requests['size'], '20');
    expect(find.text('Showing 1–20 of 24'), findsOneWidget);
  });

  testWidgets('sorting sends the sort parameter to the backend', (tester) async {
    final sorts = <String>[];
    final client = MockClient((request) async {
      sorts.add(request.url.queryParameters['sort'] ?? '');
      return http.Response(pageJson(), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));
    expect(sorts.first, 'createdAt,desc');

    await tester.tap(find.text('VEHICLE NO'));
    await tester.pumpAndSettle();
    expect(sorts.last, 'vehicleNumber,asc');

    await tester.tap(find.text('VEHICLE NO'));
    await tester.pumpAndSettle();
    expect(sorts.last, 'vehicleNumber,desc');
  });

  testWidgets('delete flow confirms, calls the API and shows the empty state', (tester) async {
    var deleteCalled = false;
    final client = MockClient((request) async {
      if (request.method == 'DELETE') {
        deleteCalled = true;
        return http.Response('', 204);
      }
      final total = deleteCalled ? 0 : 1;
      return http.Response(
        pageJson(total: total),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await pumpDesktop(tester, vehiclesApp(client));
    expect(find.text('DHA-GA-11-1001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vehicle.delete.1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete vehicle?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete.confirm')));
    await tester.pumpAndSettle();

    expect(deleteCalled, true);
    expect(find.text('No vehicles in the register yet'), findsOneWidget);
  });

  testWidgets('cancel keeps the vehicle in the register', (tester) async {
    var deleteCalled = false;
    final client = MockClient((request) async {
      if (request.method == 'DELETE') {
        deleteCalled = true;
        return http.Response('', 204);
      }
      return http.Response(pageJson(total: 1), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('vehicle.delete.1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalled, false);
    expect(find.text('DHA-GA-11-1001'), findsOneWidget);
  });

  testWidgets('shows the empty state when the register has no vehicles', (tester) async {
    final client = MockClient((request) async {
      return http.Response(pageJson(total: 0), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    expect(find.text('No vehicles in the register yet'), findsOneWidget);
    expect(find.byKey(const Key('vehicles.emptyAdd')), findsOneWidget);
  });

  testWidgets('shows an error banner and retries', (tester) async {
    var attempts = 0;
    final client = MockClient((request) async {
      attempts++;
      if (attempts == 1) {
        return jsonResponse({'status': 500, 'message': 'Fleet register unavailable.'}, status: 500);
      }
      return http.Response(pageJson(total: 1), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    expect(find.byKey(const Key('vehicles.error')), findsOneWidget);
    expect(find.text('Fleet register unavailable.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vehicles.error')), findsNothing);
    expect(find.text('DHA-GA-11-1001'), findsOneWidget);
  });

  testWidgets('data table renders on wide screens and cards on narrow ones', (tester) async {
    final client = MockClient((request) async {
      return http.Response(pageJson(total: 2), 200, headers: {'content-type': 'application/json'});
    });

    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(vehiclesApp(client));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('DHA-GA-11-1001'), findsOneWidget);
    expect(find.text('Stark Construction · Pickup'), findsWidgets);
    expect(find.text('Showing 1–2 of 2'), findsOneWidget);
  });

  testWidgets('parses duplicate-number conflict from the backend', (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        return jsonResponse(
          {
            'status': 409,
            'message': "Vehicle number 'DHA-GA-11-9001' already exists.",
            'fieldErrors': {'vehicleNumber': 'Vehicle number already exists.'},
          },
          status: 409,
        );
      }
      return http.Response(pageJson(total: 0), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('vehicles.add')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('vehicleForm.number')), 'DHA-GA-11-9001');
    await tester.enterText(find.byKey(const Key('vehicleForm.company')), 'Stark Construction');
    await tester.enterText(find.byKey(const Key('vehicleForm.brand')), 'Toyota');
    await tester.enterText(find.byKey(const Key('vehicleForm.model')), 'Hilux');

    await tester.ensureVisible(find.byKey(const Key('vehicleForm.save')));
    await tester.tap(find.byKey(const Key('vehicleForm.save')));
    await tester.pumpAndSettle();

    expect(find.text('Vehicle number already exists.'), findsOneWidget);
    expect(find.byKey(const Key('vehicleForm.save')), findsOneWidget);
  });

  testWidgets('register request body matches the backend contract', (tester) async {
    Map<String, dynamic>? posted;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        posted = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(vehicleJson(id: 42, number: posted!['vehicleNumber'] as String), status: 201);
      }
      return http.Response(pageJson(total: 0), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('vehicles.add')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('vehicleForm.number')), 'dha-ga-11-9100');
    await tester.enterText(find.byKey(const Key('vehicleForm.company')), 'Stark Logistics');
    await tester.enterText(find.byKey(const Key('vehicleForm.brand')), 'Toyota');
    await tester.enterText(find.byKey(const Key('vehicleForm.model')), 'Corolla Cross');

    await tester.ensureVisible(find.byKey(const Key('vehicleForm.save')));
    await tester.tap(find.byKey(const Key('vehicleForm.save')));
    await tester.pumpAndSettle();

    expect(posted, isNotNull);
    expect(posted!.keys, containsAll(<String>['vehicleNumber', 'company', 'type', 'brand', 'model', 'status']));
    expect(posted!['vehicleNumber'], 'DHA-GA-11-9100');
    expect(posted!['company'], 'Stark Logistics');
    expect(posted!['type'], 'CAR');
    expect(posted!['brand'], 'Toyota');
    expect(posted!['model'], 'Corolla Cross');
    expect(posted!['status'], 'ACTIVE');
  });

  testWidgets('edit dialog is pre-filled and PUTs the updated record', (tester) async {
    Map<String, dynamic>? updated;
    final client = MockClient((request) async {
      if (request.method == 'PUT') {
        updated = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(vehicleJson(id: 1, number: 'DHA-GA-11-1001', model: 'Land Cruiser'), status: 200);
      }
      return http.Response(pageJson(total: 1), 200, headers: {'content-type': 'application/json'});
    });

    await pumpDesktop(tester, vehiclesApp(client));

    await tester.tap(find.byKey(const Key('vehicle.edit.1')));
    await tester.pumpAndSettle();

    final numberField = tester.widget<TextFormField>(find.byKey(const Key('vehicleForm.number')));
    expect(numberField.controller?.text, 'DHA-GA-11-1001');

    await tester.enterText(find.byKey(const Key('vehicleForm.model')), 'Land Cruiser');
    await tester.ensureVisible(find.byKey(const Key('vehicleForm.save')));
    await tester.tap(find.byKey(const Key('vehicleForm.save')));
    await tester.pumpAndSettle();

    expect(updated, isNotNull);
    expect(updated!['model'], 'Land Cruiser');
    expect(updated!['vehicleNumber'], 'DHA-GA-11-1001');
  });
}
