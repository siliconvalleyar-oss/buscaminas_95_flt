import 'package:flutter_test/flutter_test.dart';
import 'package:buscaminas/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BuscaminasApp());
    await tester.pump();
    expect(find.byType(BuscaminasApp), findsOneWidget);
  });
}
