import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_exception.dart';
import '../core/theme.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

/// One dialog handles both Register and Edit so validation and server-error
/// handling stay identical in both flows.
class VehicleFormDialog extends StatefulWidget {
  const VehicleFormDialog({
    super.key,
    required this.vehicleService,
    this.existing,
  });

  final VehicleService vehicleService;
  final Vehicle? existing;

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _company;
  late final TextEditingController _brand;
  late final TextEditingController _model;

  late VehicleType _type;
  late VehicleStatus _status;

  bool _saving = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _number = TextEditingController(text: existing?.vehicleNumber ?? '');
    _company = TextEditingController(text: existing?.company ?? '');
    _brand = TextEditingController(text: existing?.brand ?? '');
    _model = TextEditingController(text: existing?.model ?? '');
    _type = existing?.type ?? VehicleType.car;
    _status = existing?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _number.dispose();
    _company.dispose();
    _brand.dispose();
    _model.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() {
        _fieldErrors = Map<String, String>.from(_fieldErrors)..remove(field);
      });
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = Vehicle(
      vehicleNumber: _number.text.trim().toUpperCase(),
      company: _company.text.trim(),
      type: _type,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      status: _status,
    );

    setState(() => _saving = true);
    try {
      final existing = widget.existing;
      final saved = existing == null
          ? await widget.vehicleService.createVehicle(draft)
          : await widget.vehicleService.updateVehicle(existing.id!, draft);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(saved);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _fieldErrors = error.fieldErrors;
        _error = error.fieldErrors.isEmpty ? error.message : null;
      });
      _formKey.currentState?.validate();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = 'Could not save the vehicle. Please try again.';
      });
    }
  }

  String? _validateNumber(String? value) {
    final server = _fieldErrors['vehicleNumber'];
    if (server != null) {
      return server;
    }
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty) {
      return 'Vehicle number is required';
    }
    if (normalized.length < 4 || normalized.length > 20) {
      return 'Use 4-20 characters';
    }
    if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(normalized)) {
      return 'Letters, numbers and dashes only';
    }
    return null;
  }

  String? _validateCompany(String? value) {
    final server = _fieldErrors['company'];
    if (server != null) {
      return server;
    }
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Company is required';
    }
    if (trimmed.length < 2 || trimmed.length > 60) {
      return 'Use 2-60 characters';
    }
    return null;
  }

  String? _validateBrand(String? value) {
    final server = _fieldErrors['brand'];
    if (server != null) {
      return server;
    }
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Brand is required';
    }
    if (trimmed.length < 2 || trimmed.length > 40) {
      return 'Use 2-40 characters';
    }
    return null;
  }

  String? _validateModel(String? value) {
    final server = _fieldErrors['model'];
    if (server != null) {
      return server;
    }
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Model is required';
    }
    if (trimmed.length < 2 || trimmed.length > 40) {
      return 'Use 2-40 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660, maxHeight: 740),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 520;
              return Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    _sectionLabel('VEHICLE'),
                    const SizedBox(height: 12),
                    _pair(
                      wide,
                      TextFormField(
                        key: const Key('vehicleForm.number'),
                        controller: _number,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        onChanged: (_) => _clearFieldError('vehicleNumber'),
                        decoration: const InputDecoration(
                          labelText: 'Vehicle number *',
                          hintText: 'DHA-GA-11-1234',
                        ),
                        validator: _validateNumber,
                      ),
                      DropdownButtonFormField<VehicleType>(
                        key: const Key('vehicleForm.type'),
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type *'),
                        items: [
                          for (final type in VehicleType.values)
                            DropdownMenuItem<VehicleType>(
                              value: type,
                              child: Text(type.label),
                            ),
                        ],
                        onChanged: _saving ? null : (value) => setState(() => _type = value ?? _type),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('vehicleForm.company'),
                      controller: _company,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => _clearFieldError('company'),
                      decoration: const InputDecoration(
                        labelText: 'Company *',
                        hintText: 'Stark Construction',
                      ),
                      validator: _validateCompany,
                    ),
                    const SizedBox(height: 16),
                    _pair(
                      wide,
                      TextFormField(
                        key: const Key('vehicleForm.brand'),
                        controller: _brand,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => _clearFieldError('brand'),
                        decoration: const InputDecoration(labelText: 'Brand *', hintText: 'Toyota'),
                        validator: _validateBrand,
                      ),
                      TextFormField(
                        key: const Key('vehicleForm.model'),
                        controller: _model,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => _clearFieldError('model'),
                        decoration: const InputDecoration(labelText: 'Model *', hintText: 'Hilux'),
                        validator: _validateModel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VehicleStatus>(
                      key: const Key('vehicleForm.status'),
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final status in VehicleStatus.values)
                          DropdownMenuItem<VehicleStatus>(
                            value: status,
                            child: Text(status.label),
                          ),
                      ],
                      onChanged: _saving ? null : (value) => setState(() => _status = value ?? _status),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        key: const Key('vehicleForm.error'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: StarkColors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: StarkColors.red.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, size: 17, color: StarkColors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFFB0182A), height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          key: const Key('vehicleForm.cancel'),
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 150,
                          child: FilledButton(
                            key: const Key('vehicleForm.save'),
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                  )
                                : Text(_isEdit ? 'Save changes' : 'Register vehicle'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: StarkColors.cyan.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_isEdit ? Icons.edit_outlined : Icons.add_road_outlined, size: 20, color: StarkColors.cyanDeep),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? 'Edit vehicle' : 'Register vehicle',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: StarkColors.ink, letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),
              Text(
                _isEdit
                    ? 'Update ${widget.existing!.vehicleNumber} in the Stark Group fleet register.'
                    : 'Add a new unit to the Stark Group fleet register.',
                style: const TextStyle(fontSize: 12.5, color: StarkColors.inkMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          tooltip: 'Close',
          icon: const Icon(Icons.close, size: 20),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: StarkColors.inkMuted,
      ),
    );
  }

  Widget _pair(bool wide, Widget first, Widget second) {
    if (!wide) {
      return Column(
        children: [
          first,
          const SizedBox(height: 16),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: second),
      ],
    );
  }
}
