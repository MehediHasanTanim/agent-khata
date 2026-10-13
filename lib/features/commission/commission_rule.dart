import 'dart:convert';

import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

enum CommissionMode {
  /// `value` = paisa earned per ৳1,000 of amount.
  perThousand('per_thousand'),

  /// `value` = basis points (100 = 1%).
  percent('percent'),

  /// `value` = flat paisa per transaction.
  fixed('fixed'),

  /// The rate depends on the transaction amount: see [CommissionTier]. The
  /// rule's `value` is unused.
  tiered('tiered');

  const CommissionMode(this.dbName);
  final String dbName;

  static CommissionMode fromDb(String v) =>
      CommissionMode.values.firstWhere((m) => m.dbName == v);
}

/// One band of a tiered rule: transactions up to [upTo] (inclusive) use
/// this tier's rate. The last tier has `upTo == null` (no upper bound).
///
/// Bands select a single rate for the whole amount; they are not marginal
/// slices. [mode] is never [CommissionMode.tiered].
class CommissionTier {
  const CommissionTier({this.upTo, required this.mode, required this.value})
    : assert(mode != CommissionMode.tiered);

  final Money? upTo;
  final CommissionMode mode;

  /// In the units of [mode] (see [CommissionMode]).
  final int value;

  Map<String, Object?> toJson() => {
    'up_to': upTo?.paisa,
    'mode': mode.dbName,
    'value': value,
  };

  static CommissionTier fromJson(Map<String, Object?> j) => CommissionTier(
    upTo: j['up_to'] == null ? null : Money.paisa(j['up_to']! as int),
    mode: CommissionMode.fromDb(j['mode']! as String),
    value: j['value']! as int,
  );

  @override
  bool operator ==(Object other) =>
      other is CommissionTier &&
      other.upTo == upTo &&
      other.mode == mode &&
      other.value == value;

  @override
  int get hashCode => Object.hash(upTo, mode, value);
}

/// Why a tier list cannot be used (null when valid).
String? validateTiers(List<CommissionTier> tiers) {
  if (tiers.isEmpty) return 'empty';
  Money? previous;
  for (var i = 0; i < tiers.length; i++) {
    final t = tiers[i];
    if (t.mode == CommissionMode.tiered) return 'nested';
    final last = i == tiers.length - 1;
    if (last) {
      if (t.upTo != null) return 'last_not_open';
    } else {
      final bound = t.upTo;
      if (bound == null) return 'open_in_middle';
      if (!bound.isPositive) return 'bound_not_positive';
      if (previous != null && bound <= previous) return 'not_ascending';
      previous = bound;
    }
  }
  return null;
}

String encodeTiers(List<CommissionTier> tiers) =>
    jsonEncode([for (final t in tiers) t.toJson()]);

List<CommissionTier> decodeTiers(String? json) {
  if (json == null || json.isEmpty) return const [];
  return [
    for (final e in jsonDecode(json) as List<Object?>)
      CommissionTier.fromJson(Map<String, Object?>.from(e! as Map)),
  ];
}

/// A user-configured, effective-dated commission (or margin) rule.
class CommissionRule {
  const CommissionRule({
    required this.id,
    required this.provider,
    required this.txnType,
    required this.mode,
    required this.value,
    required this.effectiveFrom,
    this.effectiveTo,
    this.tiers = const [],
  });

  final String id;

  /// `bkash`, `nagad`, `gp`, ...
  final String provider;
  final TransactionType txnType;
  final CommissionMode mode;
  final int value;

  /// Bands for [CommissionMode.tiered] (ascending, last one open-ended).
  final List<CommissionTier> tiers;

  /// Inclusive.
  final DateTime effectiveFrom;

  /// Exclusive; null = open-ended.
  final DateTime? effectiveTo;

  bool isEffectiveAt(DateTime at) =>
      !at.isBefore(effectiveFrom) &&
      (effectiveTo == null || at.isBefore(effectiveTo!));
}
