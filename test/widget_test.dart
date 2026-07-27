import 'package:flutter_test/flutter_test.dart';
import 'package:systems_studio/main.dart';

void main() {
  testWidgets('Systems Studio launches', (WidgetTester tester) async {
    await tester.pumpWidget(const SystemsStudioApp());
    await tester.pump();

    expect(find.byType(SystemsStudioApp), findsOneWidget);
  });
}
