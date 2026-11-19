import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'services/auth_service.dart';
import 'services/session_store.dart';
import 'services/vehicle_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authService = AuthService(apiClient: apiClient, sessionStore: SessionStore());
  final vehicleService = VehicleService(apiClient: apiClient);

  runApp(StarkVmsApp(authService: authService, vehicleService: vehicleService));
}
