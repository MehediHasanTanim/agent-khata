import 'package:agentkhata/core/i18n/digit_formatter.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/entry/amount_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    required void Function(String) onKey,
    required VoidCallback onBackspace,
    required void Function(Money) onChip,
    DigitStyle style = DigitStyle.latin,
    double textScale = 1,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: AmountKeypad(
            digits: DigitFormatter(style: style),
            chips: const [Money.taka(500), Money.taka(1000)],
            onKey: onKey,
            onBackspace: onBackspace,
            onChip: onChip,
          ),
        ),
      ),
    ),
  );

  testWidgets('keys, 000, backspace and chips report their input', (
    tester,
  ) async {
    final keys = <String>[];
    var backspaces = 0;
    final chips = <Money>[];
    await tester.pumpWidget(
      host(onKey: keys.add, onBackspace: () => backspaces++, onChip: chips.add),
    );

    await tester.tap(find.byKey(const ValueKey('key-7')));
    await tester.tap(find.byKey(const ValueKey('key-000')));
    await tester.tap(find.byKey(const ValueKey('key-backspace')));
    await tester.tap(
      find.byKey(ValueKey('chip-${const Money.taka(1000).paisa}')),
    );

    expect(keys, ['7', '000']);
    expect(backspaces, 1);
    expect(chips, [const Money.taka(1000)]);
  });

  testWidgets('shows Bangla digits but reports ASCII keys', (tester) async {
    final keys = <String>[];
    await tester.pumpWidget(
      host(
        onKey: keys.add,
        onBackspace: () {},
        onChip: (_) {},
        style: DigitStyle.bangla,
      ),
    );
    expect(find.text('৭'), findsOneWidget);
    await tester.tap(find.text('৭'));
    expect(keys, ['7']);
  });

  testWidgets('keys keep a 48dp+ tap target at 1.5x text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(onKey: (_) {}, onBackspace: () {}, onChip: (_) {}, textScale: 1.5),
    );
    final size = tester.getSize(find.byKey(const ValueKey('key-5')));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });
}
