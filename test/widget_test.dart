import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signverse/main.dart';

void main() {
  testWidgets('SignVerse app shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SignVerseApp()),
    );

    expect(find.text('SignVerse'), findsOneWidget);
  });
}
