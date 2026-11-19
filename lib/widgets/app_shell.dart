import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/user.dart';
import 'brand_mark.dart';

/// Application chrome: 250px navy sidebar on wide screens, drawer on narrow ones.
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

        return Scaffold(
          backgroundColor: StarkColors.canvas,
          drawer: wide
              ? null
              : Drawer(
                  width: 272,
                  backgroundColor: Colors.transparent,
                  child: sidebar,
                ),
          body: wide
              ? Row(
                  children: [
                    SizedBox(width: 250, child: sidebar),
                    Expanded(child: child),
                  ],
                )
              : Column(
                  children: [
                    _MobileBar(user: user, onSignOut: onSignOut),
                    Expanded(child: child),
                  ],
                ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.user, required this.onSignOut});

  final User user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [StarkColors.navy, StarkColors.navySoft, Color(0xFF001A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandWordmark(markSize: 38, compact: true),
              const SizedBox(height: 34),
              const _NavItem(icon: Icons.directions_car_filled, label: 'Vehicles', selected: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: StarkColors.cyan.withValues(alpha: 0.18),
                      child: Text(
                        user.initials,
                        style: const TextStyle(color: StarkColors.cyan, fontWeight: FontWeight.w800, fontSize: 13),
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
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.roleLabel,
                            style: const TextStyle(color: Colors.white54, fontSize: 10.5, letterSpacing: 0.6),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('shell.signout'),
                      onPressed: onSignOut,
                      tooltip: 'Sign out',
                      iconSize: 18,
                      color: Colors.white70,
                      hoverColor: Colors.white.withValues(alpha: 0.08),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Stark Group VMS',
                style: TextStyle(color: Colors.white38, fontSize: 10.5, letterSpacing: 0.4),
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
    final foreground = selected ? Colors.white : Colors.white.withValues(alpha: 0.65);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.09) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border(
          left: BorderSide(
            color: selected ? StarkColors.cyan : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: selected ? StarkColors.cyan : foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [StarkColors.navy, StarkColors.navySoft],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Builder(
                builder: (innerContext) => IconButton(
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  tooltip: 'Open navigation',
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ),
              const SizedBox(width: 2),
              const BrandWordmark(markSize: 30, compact: true),
              const Spacer(),
              IconButton(
                onPressed: onSignOut,
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
