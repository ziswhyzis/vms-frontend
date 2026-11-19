import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';

/// Server-side pagination controls. Mirrors the Spring Page payload:
/// `number`, `size`, `totalElements`, `totalPages`, `last`.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final first = totalElements == 0 ? 0 : page * size + 1;
    final lastVisible = totalElements == 0 ? 0 : page * size + (totalElements - page * size).clamp(0, size);
    final label = totalElements == 0
        ? 'No vehicles'
        : 'Showing $first–$lastVisible of $totalElements';
    final currentPage = totalPages == 0 ? 1 : page + 1;
    final pageCount = totalPages == 0 ? 1 : totalPages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final summary = Text(
          label,
          key: const Key('pagination.summary'),
          style: const TextStyle(fontSize: 12.5, color: StarkColors.inkMuted, fontWeight: FontWeight.w500),
        );

        final controls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rows', style: TextStyle(fontSize: 12, color: StarkColors.inkMuted)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: StarkColors.line),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  key: const Key('pagination.size'),
                  value: AppConfig.pageSizes.contains(size) ? size : AppConfig.pageSizes.first,
                  isDense: true,
                  style: const TextStyle(fontSize: 12.5, color: StarkColors.ink, fontWeight: FontWeight.w600),
                  icon: const Icon(Icons.expand_more, size: 18),
                  items: [
                    for (final option in AppConfig.pageSizes)
                      DropdownMenuItem<int>(value: option, child: Text('$option')),
                  ],
                  onChanged: (value) {
                    if (value != null && value != size) {
                      onSizeChanged(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 18),
            _PageButton(
              key: const Key('pagination.prev'),
              icon: Icons.chevron_left,
              tooltip: 'Previous page',
              onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Page $currentPage of $pageCount',
                style: const TextStyle(fontSize: 12.5, color: StarkColors.ink, fontWeight: FontWeight.w600),
              ),
            ),
            _PageButton(
              key: const Key('pagination.next'),
              icon: Icons.chevron_right,
              tooltip: 'Next page',
              onPressed: last ? null : () => onPageChanged(page + 1),
            ),
          ],
        );

        if (compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [controls]),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              summary,
              const Spacer(),
              controls,
            ],
          ),
        );
      },
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: 18,
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 30),
        padding: EdgeInsets.zero,
        side: const BorderSide(color: StarkColors.line),
        backgroundColor: Colors.white,
        disabledBackgroundColor: StarkColors.canvas,
      ),
      icon: Icon(icon),
    );
  }
}
