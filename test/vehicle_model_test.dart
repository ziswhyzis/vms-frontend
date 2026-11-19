import 'package:flutter_test/flutter_test.dart';
import 'package:stark_group_vms/models/vehicle.dart';

import 'test_support.dart';

void main() {
  group('Vehicle model', () {
    test('parses a backend vehicle payload', () {
      final vehicle = Vehicle.fromJson(
        vehicleJson(id: 7, number: 'DHA-GA-11-1007', type: 'SUV', status: 'MAINTENANCE'),
      );

      expect(vehicle.id, 7);
      expect(vehicle.vehicleNumber, 'DHA-GA-11-1007');
      expect(vehicle.company, 'Stark Construction');
      expect(vehicle.brandAndModel, 'Toyota Hilux');
      expect(vehicle.type, VehicleType.suv);
      expect(vehicle.status, VehicleStatus.maintenance);
    });

    test('serialises the request body in the backend contract shape', () {
      final vehicle = Vehicle(
        vehicleNumber: ' dha-ga-11-2001 ',
        company: ' Stark Construction ',
        type: VehicleType.pickup,
        brand: ' Toyota ',
        model: ' Hilux ',
        status: VehicleStatus.active,
      );

      final json = vehicle.toJson();

      expect(json.keys, containsAll(<String>['vehicleNumber', 'company', 'type', 'brand', 'model', 'status']));
      expect(json['vehicleNumber'], 'DHA-GA-11-2001');
      expect(json['company'], 'Stark Construction');
      expect(json['type'], 'PICKUP');
      expect(json['brand'], 'Toyota');
      expect(json['model'], 'Hilux');
      expect(json['status'], 'ACTIVE');
      expect(json.containsKey('id'), false);
    });

    test('unknown enums fall back safely', () {
      final vehicle = Vehicle.fromJson(vehicleJson(type: 'SPACESHIP', status: 'LOST'));

      expect(vehicle.type, VehicleType.car);
      expect(vehicle.status, VehicleStatus.active);
    });
  });

  group('VehiclePage', () {
    test('reads the seven Spring Page fields', () {
      final page = VehiclePage.fromJson({
        'content': [vehicleJson(id: 1), vehicleJson(id: 2)],
        'number': 1,
        'size': 10,
        'totalElements': 24,
        'totalPages': 3,
        'last': false,
      });

      expect(page.content, hasLength(2));
      expect(page.number, 1);
      expect(page.size, 10);
      expect(page.totalElements, 24);
      expect(page.totalPages, 3);
      expect(page.last, false);
      expect(page.firstVisible, 11);
      expect(page.lastVisible, 12);
    });

    test('empty page reports zero bounds', () {
      final page = VehiclePage.fromJson({
        'content': [],
        'number': 0,
        'size': 10,
        'totalElements': 0,
        'totalPages': 0,
        'last': true,
      });

      expect(page.firstVisible, 0);
      expect(page.lastVisible, 0);
      expect(VehiclePage.empty.totalElements, 0);
    });
  });
}
