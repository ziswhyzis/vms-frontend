enum VehicleType { car, suv, pickup, van, truck, bus }

enum VehicleStatus { active, inactive, maintenance }

extension VehicleTypeX on VehicleType {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        VehicleType.car => 'Car',
        VehicleType.suv => 'SUV',
        VehicleType.pickup => 'Pickup',
        VehicleType.van => 'Van',
        VehicleType.truck => 'Truck',
        VehicleType.bus => 'Bus',
      };
}

extension VehicleStatusX on VehicleStatus {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        VehicleStatus.active => 'Active',
        VehicleStatus.inactive => 'Inactive',
        VehicleStatus.maintenance => 'Maintenance',
      };
}

VehicleType vehicleTypeFromApi(Object? value) {
  final raw = (value ?? '').toString().toUpperCase();
  return VehicleType.values.firstWhere(
    (type) => type.apiValue == raw,
    orElse: () => VehicleType.car,
  );
}

VehicleStatus vehicleStatusFromApi(Object? value) {
  final raw = (value ?? '').toString().toUpperCase();
  return VehicleStatus.values.firstWhere(
    (status) => status.apiValue == raw,
    orElse: () => VehicleStatus.active,
  );
}

class Vehicle {
  const Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    this.status = VehicleStatus.active,
  });

  final int? id;
  final String vehicleNumber;
  final String company;
  final VehicleType type;
  final String brand;
  final String model;
  final VehicleStatus status;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] as num?)?.toInt(),
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: vehicleTypeFromApi(json['type']),
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: vehicleStatusFromApi(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'company': company.trim(),
      'type': type.apiValue,
      'brand': brand.trim(),
      'model': model.trim(),
      'status': status.apiValue,
    };
  }

  String get brandAndModel => '$brand $model';
}

/// Spring Page payload: content, number, size, totalElements, totalPages, last.
class VehiclePage {
  const VehiclePage({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  final List<Vehicle> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  static const VehiclePage empty = VehiclePage(
    content: [],
    number: 0,
    size: 10,
    totalElements: 0,
    totalPages: 0,
    last: true,
  );

  factory VehiclePage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final items = rawContent is List ? rawContent : const <dynamic>[];
    return VehiclePage(
      content: items
          .whereType<Map<String, dynamic>>()
          .map(Vehicle.fromJson)
          .toList(growable: false),
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }

  int get firstVisible => totalElements == 0 ? 0 : number * size + 1;

  int get lastVisible => totalElements == 0 ? 0 : number * size + content.length;
}
