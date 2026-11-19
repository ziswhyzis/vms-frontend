import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stark_group_vms/core/api_client.dart';
import 'package:stark_group_vms/core/api_exception.dart';

import 'test_support.dart';

void main() {
  group('ApiClient', () {
    test('sends bearer token and serialises query parameters', () async {
      http.Request? captured;
      final client = testApiClient(MockClient((request) async {
        captured = request;
        return jsonResponse({'ok': true});
      }));
      client.setToken('abc-123');

      final result = await client.get('/vehicles', query: {
        'page': 2,
        'size': 10,
        'sort': 'vehicleNumber,asc',
      });

      expect((result as Map<String, dynamic>)['ok'], true);
      expect(captured!.method, 'GET');
      expect(captured!.url.path, '/vehicles');
      expect(captured!.url.queryParameters['page'], '2');
      expect(captured!.url.queryParameters['size'], '10');
      expect(captured!.url.queryParameters['sort'], 'vehicleNumber,asc');
      expect(captured!.headers['Authorization'], 'Bearer abc-123');
      expect(captured!.headers['Content-Type'], 'application/json');
    });

    test('normalises a trailing slash in the configured base URL', () async {
      http.Request? captured;
      final client = ApiClient(
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse([]);
        }),
        baseUrl: 'https://vms-api.onrender.com/',
      );

      await client.get('/health');

      expect(captured!.url.toString(), 'https://vms-api.onrender.com/health');
    });

    test('maps a 409 payload with field errors', () async {
      final client = testApiClient(MockClient((request) async {
        return jsonResponse(
          {
            'status': 409,
            'message': "Vehicle number 'DHA-GA-11-1001' already exists.",
            'fieldErrors': {'vehicleNumber': 'Vehicle number already exists.'},
          },
          status: 409,
        );
      }));

      await expectLater(
        client.post('/vehicles', {'vehicleNumber': 'DHA-GA-11-1001'}),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 409)
              .having((error) => error.isConflict, 'isConflict', true)
              .having((error) => error.message, 'message', contains('already exists'))
              .having((error) => error.fieldErrors['vehicleNumber'], 'field error',
                  'Vehicle number already exists.'),
        ),
      );
    });

    test('maps a 400 validation payload', () async {
      final client = testApiClient(MockClient((request) async {
        return jsonResponse(
          {
            'status': 400,
            'message': 'Validation failed - brand: Brand is required',
            'fieldErrors': {'brand': 'Brand is required'},
          },
          status: 400,
        );
      }));

      await expectLater(
        client.post('/vehicles', {}),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 400)
              .having((error) => error.isValidationError, 'isValidationError', true),
        ),
      );
    });

    test('returns null for an empty 204 response', () async {
      final client = testApiClient(MockClient((request) async => http.Response('', 204)));
      expect(await client.delete('/vehicles/1'), isNull);
    });

    test('reports an unreachable backend', () async {
      final client = testApiClient(MockClient((request) async {
        throw const SocketExceptionStub();
      }));

      await expectLater(
        client.get('/vehicles'),
        throwsA(isA<ApiException>().having((error) => error.statusCode, 'status', 0)),
      );
    });
  });

  group('Pagination contract', () {
    test('PageResponse JSON is ingested verbatim', () async {
      final client = testApiClient(MockClient((request) async {
        final page = int.parse(request.url.queryParameters['page'] ?? '0');
        return http.Response(
          pageJson(page: page),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final payload = await client.get('/vehicles', query: {'page': 0, 'size': 10});
      final decoded = payload as Map<String, dynamic>;

      expect(decoded.keys.toSet(), {'content', 'number', 'size', 'totalElements', 'totalPages', 'last'});
      expect(decoded['content'], hasLength(10));
      expect(decoded['totalElements'], 24);
      expect(decoded['totalPages'], 3);
      expect(decoded['last'], false);
    });
  });

  test('jsonEncode sanity for page fixture', () {
    expect(jsonDecode(pageJson(page: 2))['content'], hasLength(4));
  });
}

/// Stand-in for a socket failure so tests do not need dart:io.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
