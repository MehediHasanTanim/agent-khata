import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/features/closeday/reconciliation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = ReconciliationEngine();
  final t0 = DateTime.utc(2026, 10, 20, 8);

  DayEntry e(
    String id,
    String account,
    int taka, {
    TransactionType type = TransactionType.cashOut,
    int minutes = 0,
  }) => DayEntry(
    txnId: id,
    type: type,
    occurredAt: t0.add(Duration(minutes: minutes)),
    accountId: account,
    deltaPaisa: taka * 100,
  );

  List<Suggestion> run(Map<String, int> varianceTaka, List<DayEntry> entries) =>
      engine.analyze(
        variancePaisa: {
          for (final x in varianceTaka.entries) x.key: x.value * 100,
        },
        entries: entries,
      );

  test('no variance, no suggestions', () {
    expect(run({'cash': 0}, [e('a', 'cash', 500)]), isEmpty);
  });

  test('entry equal to the gap, same direction: probably missing a twin', () {
    // Cash is 500 short; an existing entry moved cash by -500.
    final s = run({'cash': -500}, [e('a', 'cash', -500), e('b', 'cash', 200)]);
    expect(s.first.kind, SuggestionKind.sameAmountEntry);
    expect(s.first.txnId, 'a');
    expect(s.first.sameDirection, isTrue);
  });

  test('entry equal to the gap, opposite direction: maybe not real', () {
    final s = run({'cash': -500}, [e('a', 'cash', 500)]);
    expect(s.first.kind, SuggestionKind.sameAmountEntry);
    expect(s.first.sameDirection, isFalse);
  });

  test('flipped direction is wrong by twice the amount', () {
    // Recorded +300 but really -300: expected is 600 too high.
    final s = run({'cash': -600}, [e('a', 'cash', 300), e('b', 'cash', 50)]);
    expect(s.first.kind, SuggestionKind.flippedDirection);
    expect(s.first.txnId, 'a');
  });

  test('digit transposition: 540 typed as 450', () {
    // Booked 450 (cash -450) but really 540: cash is 90 lower than booked.
    final s = run({'cash': -90}, [e('a', 'cash', -450), e('b', 'cash', -73)]);
    final hit = s.firstWhere(
      (x) => x.kind == SuggestionKind.digitTransposition,
    );
    expect(hit.txnId, 'a');
    expect(hit.altAmountPaisa, 54000);
  });

  test('duplicates within the window outrank a plain match', () {
    final s = run(
      {'cash': 1000},
      [
        e('a', 'cash', -1000, minutes: 0),
        e('b', 'cash', -1000, minutes: 3),
        e('c', 'cash', 40, minutes: 90),
      ],
    );
    expect(s.first.kind, SuggestionKind.duplicateEntries);
    expect(s.first.txnId, 'b');
  });

  test('same amounts far apart are not duplicates', () {
    final s = run(
      {'cash': 1000},
      [e('a', 'cash', -1000, minutes: 0), e('b', 'cash', -1000, minutes: 120)],
    );
    expect(s.any((x) => x.kind == SuggestionKind.duplicateEntries), isFalse);
  });

  test('opposite variances on two accounts point at each other', () {
    final s = run({'cash': -700, 'bkash': 700}, []);
    expect(s, hasLength(2));
    final cash = s.firstWhere((x) => x.accountId == 'cash');
    expect(cash.kind, SuggestionKind.crossAccount);
    expect(cash.otherAccountId, 'bkash');
  });

  test('double amount relation has low confidence', () {
    final s = run({'cash': -250}, [e('a', 'cash', -500)]);
    expect(s.single.kind, SuggestionKind.amountRelation);
    expect(s.single.entryIsDouble, isTrue);
    expect(s.single.confidence, lessThan(0.5));
  });

  test('at most three suggestions per account, best first', () {
    final entries = [
      for (var i = 0; i < 8; i++) e('t$i', 'cash', 500, minutes: i * 30),
    ];
    final s = run({'cash': -500}, entries);
    expect(s.length, 3);
    final confs = s.map((x) => x.confidence).toList();
    expect([...confs]..sort((a, b) => b.compareTo(a)), confs);
  });

  test('entries of other accounts are ignored', () {
    expect(run({'cash': -500}, [e('a', 'bkash', 500)]), isEmpty);
  });
}
