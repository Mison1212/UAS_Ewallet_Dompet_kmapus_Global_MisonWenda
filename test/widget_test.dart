import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dompet_kampus_global/presentation/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renders without external assets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AppLogo(withText: true)),
        ),
      ),
    );

    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    expect(find.text('Dompet Kampus'), findsOneWidget);
    expect(find.text('GLOBAL'), findsOneWidget);
  });
}
