import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_group_vms/core/api_client.dart';
import 'package:stark_group_vms/models/user.dart';

const String testBaseUrl = 'http://vms.test';
const String demoToken = 'test-jwt-token';

void useEmptyPreferences() {
  SharedPreferences.setMockInitialValues({});
}

ApiClient testApiClient(http.Client client) =>
    ApiClient(httpClient: client, baseUrl: testBaseUrl);

Map<String, dynamic> userJson({
  int id = 1,
  String username = 'admin',
  String fullName = 'Stark Group Administrator',
  String role = 'ADMIN',
}) => {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
    };

User demoUser() => User.fromJson(userJson());

String loginJson({String token = demoToken}) => jsonEncode({
      'token': token,
      'expiresAt': '2026-11-17T18:00:00Z',
      'user': userJson(),
    });

String registerJson({
  String token = demoToken,
  String username = 'jane.doe',
  String fullName = 'Jane Doe',
}) => jsonEncode({
      'token': token,
      'expiresAt': '2026-11-17T18:00:00Z',
      'user': userJson(username: username, fullName: fullName),
    });

Map<String, dynamic> vehicleJson({
  int id = 1,
  String number = 'DHA-GA-11-1001',
  String company = 'Stark Construction',
  String type = 'PICKUP',
  String brand = 'Toyota',
  String model = 'Hilux',
  String status = 'ACTIVE',
}) => {
      'id': id,
      'vehicleNumber': number,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status,
    };

/// Mirrors a Spring Page payload for the paginated vehicle list.
String pageJson({int page = 0, int size = 10, int total = 24}) {
  final start = page * size;
  final count = (total - start).clamp(0, size);
  final totalPages = total == 0 ? 0 : (total / size).ceil();
  final items = [
    for (var index = 0; index < count; index++)
      vehicleJson(
        id: start + index + 1,
        number: 'DHA-GA-11-${1001 + start + index}',
        model: index.isEven ? 'Hilux' : 'Corolla Cross',
        type: index.isEven ? 'PICKUP' : 'SUV',
        company: index.isEven ? 'Stark Construction' : 'Stark Group',
        status: index % 5 == 0 ? 'MAINTENANCE' : 'ACTIVE',
      ),
  ];
  return jsonEncode({
    'content': items,
    'number': page,
    'size': size,
    'totalElements': total,
    'totalPages': totalPages,
    'last': start + count >= total,
  });
}

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
