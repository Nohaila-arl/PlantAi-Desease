import 'package:flutter_test/flutter_test.dart';
import 'package:plant_ai_mobile/main.dart';

void main() {
  testWidgets('PlantAI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PlantAIApp());
    await tester.pump();

    expect(find.text('Detect Plant'), findsOneWidget);
    expect(find.text('Diseases with AI'), findsOneWidget);
  });
}
