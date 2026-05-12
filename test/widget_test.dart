import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dipok/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const DipokApp());
    expect(find.text('Dipok Setup'), findsOneWidget);
  });
}
