import 'package:flutter_test/flutter_test.dart';
import 'package:app_firebase/main.dart';

void main() {
  testWidgets('User directory screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Directorio'), findsOneWidget);
    expect(find.text('PANEL DE DATOS'), findsOneWidget);
  });
}
