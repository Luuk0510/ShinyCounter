import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/app_image.dart';

void main() {
  testWidgets('shows fallback icon when image fails to load', (tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = (_) {};

    await tester.pumpWidget(
      const MaterialApp(
        home: AppImage(
          image: AssetImage('assets/missing_image.png'),
          fallbackIcon: Icons.broken_image,
          fallbackIconSize: 24,
          borderRadius: 0,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}
