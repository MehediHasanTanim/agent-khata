import '../../core/ledger/transaction_type.dart';

/// One transaction's effect on one account during the day being closed.
class DayEntry {
  const DayEntry({
    required this.txnId,
    required this.type,
    required this.occurredAt,
    required this.accountId,
    required this.deltaPaisa,
  });

  final String txnId;
  final TransactionType type;
  final DateTime occurredAt;
  final String accountId;

  /// Signed effect on [accountId] in paisa.
  final int deltaPaisa;
}

enum SuggestionKind {
  /// An entry's amount equals the gap. [Suggestion.sameDirection] says whether
  /// the entry moved the account the same way as the gap.
  sameAmountEntry,

  /// An entry was probably recorded with the wrong direction (in vs out).
  flippedDirection,

  /// The gap is double (or half) of an entry's amount.
  amountRelation,

  /// The same entry looks recorded twice within minutes.
  duplicateEntries,

  /// Two adjacent digits of an amount may have been swapped.
  digitTransposition,

  /// Another account is off by exactly the opposite amount.
  crossAccount,
}

/// A ranked hint for "find the gap". Text is rendered by the UI so it can be
/// shown in Bangla or English.
class Suggestion {
  const Suggestion({
    required this.kind,
    required this.accountId,
    required this.confidence,
    this.txnId,
    this.amountPaisa,
    this.altAmountPaisa,
    this.otherAccountId,
    this.sameDirection = false,
    this.entryIsDouble = false,
  });

  final SuggestionKind kind;
  final String accountId;

  /// 0..1; higher is more likely.
  final double confidence;
  final String? txnId;
  final int? amountPaisa;
  final int? altAmountPaisa;
  final String? otherAccountId;
  final bool sameDirection;

  /// For [SuggestionKind.amountRelation]: the entry is double the gap
  /// (otherwise the gap is double the entry).
  final bool entryIsDouble;
}

/// Pure "find the gap" analysis for a day close.
class ReconciliationEngine {
  const ReconciliationEngine({
    this.duplicateWindow = const Duration(minutes: 10),
  });

  final Duration duplicateWindow;

  /// [variancePaisa] is `actual - expected` per account; zero variances are
  /// ignored. Returns at most [topPerAccount] suggestions per account,
  /// best first.
  List<Suggestion> analyze({
    required Map<String, int> variancePaisa,
    required List<DayEntry> entries,
    int topPerAccount = 3,
  }) {
    final result = <Suggestion>[];
    final off = {
      for (final e in variancePaisa.entries)
        if (e.value != 0) e.key: e.value,
    };

    for (final MapEntry(key: accountId, value: v) in off.entries) {
      final av = v.abs();
      final mine = entries.where((e) => e.accountId == accountId).toList();
      final found = <String, Suggestion>{}; // best per txn id / key

      void offer(String key, Suggestion s) {
        final cur = found[key];
        if (cur == null || s.confidence > cur.confidence) found[key] = s;
      }

      for (final e in mine) {
        final d = e.deltaPaisa;
        final ad = d.abs();
        if (ad == 0) continue;
        final sameDir = (d > 0) == (v > 0);

        if (ad == av) {
          offer(
            e.txnId,
            Suggestion(
              kind: SuggestionKind.sameAmountEntry,
              accountId: accountId,
              confidence: 0.8,
              txnId: e.txnId,
              amountPaisa: ad,
              sameDirection: sameDir,
            ),
          );
        }
        // A flipped entry is wrong by twice its amount, in its opposite sign.
        if (ad * 2 == av && !sameDir) {
          offer(
            e.txnId,
            Suggestion(
              kind: SuggestionKind.flippedDirection,
              accountId: accountId,
              confidence: 0.7,
              txnId: e.txnId,
              amountPaisa: ad,
            ),
          );
        } else if (ad * 2 == av) {
          offer(
            e.txnId,
            Suggestion(
              kind: SuggestionKind.amountRelation,
              accountId: accountId,
              confidence: 0.3,
              txnId: e.txnId,
              amountPaisa: ad,
            ),
          );
        }
        if (ad == av * 2) {
          offer(
            e.txnId,
            Suggestion(
              kind: SuggestionKind.amountRelation,
              accountId: accountId,
              confidence: 0.35,
              txnId: e.txnId,
              amountPaisa: ad,
              entryIsDouble: true,
            ),
          );
        }
        if (ad % 100 == 0) {
          final alt = _transpositionMatching(
            ad ~/ 100,
            av ~/ 100,
            av % 100 == 0,
          );
          if (alt != null) {
            offer(
              e.txnId,
              Suggestion(
                kind: SuggestionKind.digitTransposition,
                accountId: accountId,
                confidence: 0.6,
                txnId: e.txnId,
                amountPaisa: ad,
                altAmountPaisa: alt * 100,
              ),
            );
          }
        }
      }

      // Duplicates: same type and amount, minutes apart, matching the gap.
      for (var i = 0; i < mine.length; i++) {
        for (var j = i + 1; j < mine.length; j++) {
          final a = mine[i];
          final b = mine[j];
          if (a.type == b.type &&
              a.deltaPaisa == b.deltaPaisa &&
              a.deltaPaisa.abs() == av &&
              a.occurredAt.difference(b.occurredAt).abs() <= duplicateWindow) {
            final later = a.occurredAt.isAfter(b.occurredAt) ? a : b;
            offer(
              later.txnId,
              Suggestion(
                kind: SuggestionKind.duplicateEntries,
                accountId: accountId,
                confidence: 0.9,
                txnId: later.txnId,
                amountPaisa: av,
              ),
            );
          }
        }
      }

      // Cross-account: another account is off by exactly the opposite.
      for (final other in off.entries) {
        if (other.key != accountId && other.value == -v) {
          offer(
            'cross:${other.key}',
            Suggestion(
              kind: SuggestionKind.crossAccount,
              accountId: accountId,
              confidence: 0.6,
              otherAccountId: other.key,
              amountPaisa: av,
            ),
          );
        }
      }

      final ranked = found.values.toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      result.addAll(ranked.take(topPerAccount));
    }
    return result;
  }

  /// If swapping two adjacent digits of [taka] changes it by exactly the
  /// whole-taka gap [gapTaka], returns the swapped value.
  int? _transpositionMatching(int taka, int gapTaka, bool gapIsWhole) {
    if (!gapIsWhole || gapTaka == 0) return null;
    final digits = taka.toString().split('');
    for (var i = 0; i + 1 < digits.length; i++) {
      if (digits[i] == digits[i + 1]) continue;
      final swapped = [...digits];
      final t = swapped[i];
      swapped[i] = swapped[i + 1];
      swapped[i + 1] = t;
      if (swapped.first == '0') continue;
      final alt = int.parse(swapped.join());
      if ((alt - taka).abs() == gapTaka) return alt;
    }
    return null;
  }
}
