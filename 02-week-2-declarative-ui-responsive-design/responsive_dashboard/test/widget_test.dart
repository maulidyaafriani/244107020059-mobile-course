

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard displays its key information', (tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('Academic Overview'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Current week'), findsOneWidget);
  });

  testWidgets('Dashboard uses one column on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(Card);
    expect(cards, findsNWidgets(4));
    expect(tester.getSize(cards.at(0)).width, lessThan(700));
  });

  testWidgets('Dashboard uses two columns on a wide screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(Card);
    expect(cards, findsNWidgets(4));
    expect(tester.getSize(cards.at(0)).width, greaterThan(400));
    expect(tester.getSize(cards.at(0)).width, lessThan(700));
  });
}
