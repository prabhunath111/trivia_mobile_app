import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_master/presentation/common/widgets/option_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the label text', (tester) async {
    await tester.pumpWidget(wrap(OptionTile(
      label: 'Canberra',
      state: OptionVisualState.idle,
      onTap: () {},
    )));

    expect(find.text('Canberra'), findsOneWidget);
  });

  testWidgets('invokes onTap when enabled and tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(OptionTile(
      label: 'Canberra',
      state: OptionVisualState.idle,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.text('Canberra'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('does not invoke onTap when disabled', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(OptionTile(
      label: 'Canberra',
      state: OptionVisualState.idle,
      enabled: false,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.text('Canberra'));
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('shows a check icon when revealed as correct', (tester) async {
    await tester.pumpWidget(wrap(OptionTile(
      label: 'Canberra',
      state: OptionVisualState.revealedCorrect,
      onTap: () {},
    )));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
