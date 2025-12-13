import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/animated_app_icon.dart';

import 'helpers/test_asset_bundle.dart';

bool _matrixIsIdentity(Matrix4 matrix, {double epsilon = 0.0001}) {
  final identity = Matrix4.identity();
  final a = matrix.storage;
  final b = identity.storage;
  for (var i = 0; i < a.length; i++) {
    if ((a[i] - b[i]).abs() > epsilon) return false;
  }
  return true;
}

void main() {
  testWidgets('tapping app icon triggers animation transform', (tester) async {
    final bundle = TestAssetBundle([AppAssets.appIcon]);
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: AnimatedAppIcon(assetPath: AppAssets.appIcon)),
          ),
        ),
      ),
    );

    Transform transform() =>
        tester.widget(find.byKey(AnimatedAppIcon.transformKey));

    expect(_matrixIsIdentity(transform().transform), isTrue);

    await tester.tap(find.byKey(AnimatedAppIcon.tapTargetKey));
    // Pump once to deliver the tap and start the controller, then advance time.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(_matrixIsIdentity(transform().transform), isFalse);

    await tester.pumpAndSettle();
    expect(_matrixIsIdentity(transform().transform), isTrue);
  });
}
