import 'package:flutter_test/flutter_test.dart';
import 'package:seismic2800/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SeismicApp());

    expect(find.byType(SeismicApp), findsOneWidget);
  });
}
