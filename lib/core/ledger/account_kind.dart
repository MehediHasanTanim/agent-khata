/// What kind of "pocket" an account is.
enum AccountKind {
  cash,
  wallet,
  load,
  bank,

  /// Expense category; counter-account for expense postings.
  expense,

  /// Hidden counter-account for money entering or leaving the agent's world
  /// (customer fees, flexiload margin, adjustments).
  external;

  String get dbName => name;

  static AccountKind fromDb(String value) =>
      AccountKind.values.firstWhere((k) => k.name == value);
}

/// Pockets the agent actually counts (shown on home, reconciled at close).
const countedKinds = {
  AccountKind.cash,
  AccountKind.wallet,
  AccountKind.load,
  AccountKind.bank,
};
