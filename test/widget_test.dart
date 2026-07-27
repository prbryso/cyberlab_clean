import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/main.dart';

void main() {
  testWidgets('CyberLab app starts', (WidgetTester tester) async {
    await tester.pumpWidget(CyberLabApp());

    expect(find.byType(CyberLabApp), findsOneWidget);
  });
}
