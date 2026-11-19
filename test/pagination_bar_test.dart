import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_group_vms/core/theme.dart';
import 'package:stark_group_vms/widgets/pagination_bar.dart';

Widget pagination({
  int page = 1,
  int size = 10,
  int totalElements = 24,
  int totalPages = 3,
  bool last = false,
  ValueChanged<int>? onPageChanged,
  ValueChanged<int>? onSizeChanged,
}) {
  return MaterialApp(
    theme: buildStarkTheme(),
    home: Scaffold(
      body: PaginationBar(
        page: page,
        size: size,
        totalElements: totalElements,
        totalPages: totalPages,
        last: last,
        onPageChanged: onPageChanged ?? (_) {},
        onSizeChanged: onSizeChanged ?? (_) {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the visible range and page counter', (tester) async {
    await tester.pumpWidget(pagination());

    expect(find.text('Showing 11–20 of 24'), findsOneWidget);
    expect(find.text('Page 2 of 3'), findsOneWidget);
  });

  testWidgets('previous and next invoke the page callback', (tester) async {
    final requested = <int>[];
    await tester.pumpWidget(pagination(onPageChanged: requested.add));

    await tester.tap(find.byKey(const Key('pagination.prev')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pagination.next')));
    await tester.pump();

    expect(requested, [0, 2]);
  });

  testWidgets('next is disabled on the last page', (tester) async {
    final requested = <int>[];
    await tester.pumpWidget(pagination(page: 2, totalPages: 3, last: true, onPageChanged: requested.add));

    expect(find.text('Showing 21–24 of 24'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pagination.next')));
    await tester.pump();
    expect(requested, isEmpty);
  });

  testWidgets('previous is disabled on the first page', (tester) async {
    final requested = <int>[];
    await tester.pumpWidget(pagination(page: 0, onPageChanged: requested.add));

    await tester.tap(find.byKey(const Key('pagination.prev')));
    await tester.pump();
    expect(requested, isEmpty);
  });

  testWidgets('shows an empty label for an empty register', (tester) async {
    await tester.pumpWidget(pagination(totalElements: 0, totalPages: 0, last: true));

    expect(find.text('No vehicles'), findsOneWidget);
    expect(find.text('Page 1 of 1'), findsOneWidget);
  });
}
