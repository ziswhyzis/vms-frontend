import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/config.dart';
import '../models/vehicle.dart';

class VehicleService {
  VehicleService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<VehiclePage> fetchVehicles({
    int page = 0,
    int size = AppConfig.defaultPageSize,
    String sort = AppConfig.defaultSort,
  }) async {
    final payload = await _api.get('/vehicles', query: {
      'page': page,
      'size': size,
      'sort': sort,
    });
    if (payload is Map<String, dynamic>) {
      return VehiclePage.fromJson(payload);
    }
    throw const ApiException(500, 'Unexpected response from the vehicle list service.');
  }

  Future<Vehicle> getVehicle(int id) async {
    final payload = await _api.get('/vehicles/$id');
    if (payload is Map<String, dynamic>) {
      return Vehicle.fromJson(payload);
    }
    throw const ApiException(500, 'Unexpected response from the vehicle service.');
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final payload = await _api.post('/vehicles', vehicle.toJson());
    if (payload is Map<String, dynamic>) {
      return Vehicle.fromJson(payload);
    }
    throw const ApiException(500, 'Unexpected response from the vehicle service.');
  }

  Future<Vehicle> updateVehicle(int id, Vehicle vehicle) async {
    final payload = await _api.put('/vehicles/$id', vehicle.toJson());
    if (payload is Map<String, dynamic>) {
      return Vehicle.fromJson(payload);
    }
    throw const ApiException(500, 'Unexpected response from the vehicle service.');
  }

  Future<void> deleteVehicle(int id) async {
    await _api.delete('/vehicles/$id');
  }
}
