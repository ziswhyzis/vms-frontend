import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/user.dart';
import 'brand_mark.dart';
import 'lattice_background.dart';

/// Sidebar and register sit as separate framed cards on the lattice,
/// the same way VS Code floats the side bar and the editor.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.onSignOut,
    required this.child,
  });

  final User user;
  final Future<void> Function() onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final sidebar = _Sidebar(user: user, onSignOut: onSignOut);

        return LatticeScaffold(
          drawer: wide
              ? null
              : Drawer(
                  width: 280,
                  backgroundColor: StarkColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(StarkChrome.radius)),
                    side: BorderSide(color: StarkColors.line),
                  ),
                  child: sidebar,
                ),
          body: Padding(
            padding: const EdgeInsets.all(StarkChrome.margin),
            child: wide
                ? Row(
                    children: [
                      SizedBox(width: 250, child: _frame(sidebar)),
                      const SizedBox(width: StarkChrome.gutter),
                      Expanded(child: _frame(child)),
                    ],
                  )
                : Column(
                    children: [
                      _frame(_MobileBar(user: user, onSignOut: onSignOut)),
                      const SizedBox(height: StarkChrome.gutter),
                      Expanded(child: _frame(child)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _frame(Widget child) {
    return DecoratedBox(
      decoration: StarkChrome.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        child: child,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.user, required this.onSignOut});

  final User user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StarkColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandWordmark(markSize: 36, compact: true),
              const SizedBox(height: 28),
              const _NavItem(icon: Icons.directions_car_filled, label: 'Vehicles', selected: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                decoration: BoxDecoration(
                  color: StarkColors.cream,
                  borderRadius: BorderRadius.circular(StarkChrome.radius),
                  border: Border.all(color: StarkColors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: StarkColors.sage.withValues(alpha: 0.45),
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: StarkColors.sageInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: StarkColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user.roleLabel,
                            style: const TextStyle(
                              color: StarkColors.inkMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('shell.signout'),
                      onPressed: onSignOut,
                      tooltip: 'Sign out',
                      iconSize: 18,
                      color: StarkColors.inkMuted,
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Stark Group VMS',
                style: TextStyle(color: StarkColors.inkMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? StarkColors.tealInk : StarkColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? StarkColors.sage.withValues(alpha: 0.32) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: selected ? StarkColors.teal : foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBar extends StatelessWidget {
  const _MobileBar({required this.user, required this.onSignOut});

  final User user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StarkColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Builder(
                builder: (innerContext) => IconButton(
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  tooltip: 'Open navigation',
                  icon: const Icon(Icons.menu, color: StarkColors.ink),
                ),
              ),
              const SizedBox(width: 2),
              const Expanded(child: BrandWordmark(markSize: 28, compact: true)),
              IconButton(
                onPressed: onSignOut,
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout, color: StarkColors.inkMuted, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
