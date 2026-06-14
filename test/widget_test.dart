// Smoke tests for the rebuilt design system. Verifies the theme and the core
// reusable kit widgets build and render without throwing, in both brightnesses,
// and that NeonButton fires its callback.

import 'package:advanced_xo_game/theme/app_theme.dart';
import 'package:advanced_xo_game/widgets/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SectionHeader(icon: Icons.bar_chart_rounded, title: 'Stats'),
            const SizedBox(height: 12),
            const GlassPanel(child: Text('Panel')),
            const SizedBox(height: 12),
            const StatCard(icon: Icons.star, label: 'Wins', value: 12),
            const SizedBox(height: 12),
            const CountUpText(value: 42, suffix: '%'),
            const SizedBox(height: 12),
            const SizedBox(width: 80, height: 80, child: AnimatedMark(mark: 'X')),
            const SizedBox(width: 80, height: 80, child: AnimatedMark(mark: 'O')),
            const ProgressRing(progress: 0.6),
            SizedBox(
              width: 120,
              height: 120,
              child: GameCell(value: 'X', highlight: false, onTap: () {}),
            ),
            const NeonButton(label: 'Play'),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('design system renders in dark theme', (tester) async {
    await tester.pumpWidget(_harness(AppTheme.dark));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('design system renders in light theme', (tester) async {
    await tester.pumpWidget(_harness(AppTheme.light));
    await tester.pumpAndSettle();
    expect(find.text('Panel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('NeonButton fires its onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: NeonButton(
              label: 'Tap',
              expand: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tap'));
    expect(tapped, isTrue);
  });
}
