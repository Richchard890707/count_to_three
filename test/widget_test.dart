import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:count_to_three/app/app.dart';

void main() {
  testWidgets('App smoke test — shell renders without crash',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    await tester.pumpAndSettle();
    expect(find.text('鬧鐘'), findsOneWidget);
    expect(find.text('行事曆'), findsOneWidget);
  });
}
