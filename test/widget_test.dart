import 'package:flutter_test/flutter_test.dart';
import 'package:lunary/core/theme/app_colors.dart';
import 'package:lunary/main.dart';

void main() {
  testWidgets('LunaryApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(LunaryApp(themeController: ThemeController()));

    // Verify that the app widget loads without errors.
    expect(find.byType(LunaryApp), findsOneWidget);
  });
}
