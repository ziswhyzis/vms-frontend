import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/status_badge.dart';
import '../widgets/vehicle_form_dialog.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({
    super.key,
    required this.vehicleService,
    required this.user,
    required this.onSignOut,
  });

  final VehicleService vehicleService;
  final User user;
  final Future<void> Function() onSignOut;

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  int _page = 0;
  int _size = AppConfig.defaultPageSize;
  String _sortField = 'createdAt';
  bool _ascending = false;

  VehiclePage? _data;
  bool _loading = true;
  String? _error;

  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _sortParam => '$_sortField,${_ascending ? 'asc' : 'desc'}';

  int? get _sortColumnIndex {
    switch (_sortField) {
      case 'vehicleNumber':
        return 0;
      case 'company':
        return 1;
      case 'type':
        return 2;
      case 'brand':
        return 3;
      default:
        return null;
    }
  }

  Future<void> _load({bool showSpinner = true}) async {
    final requestId = ++_requestId;
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await widget.vehicleService.fetchVehicles(
        page: _page,
        size: _size,
        sort: _sortParam,
      );
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _data = data;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Could not load the fleet register. Please try again.';
      });
    }
  }

  void _changePage(int page) {
    if (page == _page) {
      return;
    }
    setState(() => _page = page);
    _load();
  }

  void _changeSize(int size) {
    setState(() {
      _size = size;
      _page = 0;
    });
    _load();
  }

  void _toggleSort(String field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = true;
      }
      _page = 0;
    });
    _load();
  }

  Future<void> _openForm({Vehicle? existing}) async {
    final saved = await showDialog<Vehicle>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => VehicleFormDialog(
        vehicleService: widget.vehicleService,
        existing: existing,
      ),
    );
    if (saved == null || !mounted) {
      return;
    }
    if (existing == null) {
      setState(() {
        _sortField = 'createdAt';
        _ascending = false;
        _page = 0;
      });
    }
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Vehicle ${saved.vehicleNumber} registered in the fleet register.'
              : 'Vehicle ${saved.vehicleNumber} updated.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDeleteDialog(vehicle: vehicle),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await widget.vehicleService.deleteVehicle(vehicle.id!);
      if (!mounted) {
        return;
      }
      if (_page > 0 && (_data?.content.length ?? 0) <= 1) {
        setState(() => _page = _page - 1);
      }
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle ${vehicle.vehicleNumber} deleted from the register.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      user: widget.user,
      onSignOut: widget.onSignOut,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padded = constraints.maxWidth >= 640 ? 28.0 : 16.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(padded, padded, padded, padded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(constraints.maxWidth),
                const SizedBox(height: 18),
                Expanded(child: _panel()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(double maxWidth) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Fleet Register',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: StarkColors.ink, letterSpacing: -0.6),
            ),
            const SizedBox(width: 12),
            Container(
              key: const Key('vehicles.count'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: StarkColors.navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _data == null ? '…' : '${_data!.totalElements} vehicles',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: StarkColors.navySoft),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Every vehicle operated across the Stark Group.',
          style: TextStyle(fontSize: 12.5, color: StarkColors.inkMuted),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _loading ? null : () => _load(),
          icon: const Icon(Icons.refresh, size: 17),
          label: const Text('Refresh'),
        ),
        FilledButton.icon(
          key: const Key('vehicles.add'),
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Register Vehicle'),
        ),
      ],
    );

    if (maxWidth < 760) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 14),
          actions,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }

  Widget _panel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StarkColors.line),
        boxShadow: [
          BoxShadow(
            color: StarkColors.navy.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        // Stretch so the data table (which reports an intrinsic width) fills
        // the panel instead of being centred by the default alignment.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) _errorBanner(),
          Expanded(
            child: _loading
                ? const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  )
                : _body(),
          ),
          if (!_loading && _data != null && _data!.totalElements > 0) ...[
            const Divider(height: 1),
            PaginationBar(
              page: _page,
              size: _size,
              totalElements: _data!.totalElements,
              totalPages: _data!.totalPages,
              last: _data!.last,
              onPageChanged: _changePage,
              onSizeChanged: _changeSize,
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StarkColors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StarkColors.red.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 19, color: StarkColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              key: const Key('vehicles.error'),
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFB0182A), height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _load(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final data = _data;
    if (data == null || data.content.isEmpty) {
      return _emptyState();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return SingleChildScrollView(child: _table(data.content));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: data.content.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _vehicleCard(data.content[index]),
        );
      },
    );
  }

  Widget _table(List<Vehicle> vehicles) {
    return DataTable(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _ascending,
      horizontalMargin: 20,
      columnSpacing: 26,
      headingRowHeight: 46,
      dataRowMinHeight: 54,
      dataRowMaxHeight: 60,
      headingRowColor: WidgetStatePropertyAll(StarkColors.canvas.withValues(alpha: 0.7)),
      headingTextStyle: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: StarkColors.inkMuted,
      ),
      columns: [
        DataColumn(
          label: const Text('VEHICLE NO'),
          onSort: (_, __) => _toggleSort('vehicleNumber'),
        ),
        DataColumn(
          label: const Text('COMPANY'),
          onSort: (_, __) => _toggleSort('company'),
        ),
        DataColumn(
          label: const Text('TYPE'),
          onSort: (_, __) => _toggleSort('type'),
        ),
        DataColumn(
          label: const Text('BRAND / MODEL'),
          onSort: (_, __) => _toggleSort('brand'),
        ),
        const DataColumn(label: Text('STATUS')),
        const DataColumn(label: Text('ACTIONS')),
      ],
      rows: [
        for (final vehicle in vehicles)
          DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: StarkColors.cyan.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.directions_car_filled, size: 14, color: StarkColors.cyanDeep),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      vehicle.vehicleNumber,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: StarkColors.ink, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  vehicle.company,
                  style: const TextStyle(fontSize: 12.5, color: StarkColors.ink),
                ),
              ),
              DataCell(TypeChip(type: vehicle.type)),
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.brand,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: StarkColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.model,
                      style: const TextStyle(fontSize: 11, color: StarkColors.inkMuted),
                    ),
                  ],
                ),
              ),
              DataCell(StatusBadge(status: vehicle.status)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: Key('vehicle.edit.${vehicle.id}'),
                      tooltip: 'Edit vehicle',
                      onPressed: () => _openForm(existing: vehicle),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                    ),
                    IconButton(
                      key: Key('vehicle.delete.${vehicle.id}'),
                      tooltip: 'Delete vehicle',
                      onPressed: () => _confirmDelete(vehicle),
                      icon: const Icon(Icons.delete_outline, size: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _vehicleCard(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StarkColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vehicle.vehicleNumber,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: StarkColors.ink, letterSpacing: 0.3),
                ),
              ),
              StatusBadge(status: vehicle.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vehicle.brandAndModel,
            style: const TextStyle(fontSize: 12.5, color: StarkColors.inkMuted),
          ),
          const SizedBox(height: 2),
          Text(
            '${vehicle.company} · ${vehicle.type.label}',
            style: const TextStyle(fontSize: 11.5, color: StarkColors.inkMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Spacer(),
              IconButton(
                key: Key('vehicle.edit.${vehicle.id}'),
                tooltip: 'Edit vehicle',
                onPressed: () => _openForm(existing: vehicle),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              IconButton(
                key: Key('vehicle.delete.${vehicle.id}'),
                tooltip: 'Delete vehicle',
                onPressed: () => _confirmDelete(vehicle),
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: StarkColors.cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.garage_outlined, size: 34, color: StarkColors.cyanDeep),
            ),
            const SizedBox(height: 18),
            const Text(
              'No vehicles in the register yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: StarkColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'Register the first Stark Group vehicle to start the register.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: StarkColors.inkMuted, height: 1.5),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('vehicles.emptyAdd'),
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Register Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
